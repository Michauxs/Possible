//
//  MXSPVPController.swift
//  Possible
//
//  Created by Sunfei on 2021/7/30.
//  Copyright © 2021 boyuan. All rights reserved.
//

import UIKit

class MXSPVPController: MXSGroundController {
    
    override func didCloseGameBtnClick() {
        MXSPokerCmd.shared.packagePoker()
        MXSNetServ.shared.sendMessage(.init(type: .endGame, content: 1))
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func readyModelForView() {
        pickHeroView.pickType = .PVP
    }
    
    override func pickedHero(_ hero: MXSHero, chairNumb: Int = 0) {
        player = hero
        player.isAxle = true
        player.concreteView = playerView
        
        player.joingame()
        pickHeroView.isHidden = true
        MXSNetServ.shared.sendMessage(.init(type: .pickHero, content: hero.photo))
    }
    
    override func haveAmessage(_ model: MessageModel) {
        super.haveAmessage(model)
        
        switch model.type {
        case .joined:
            MXSLog("some one joined game")
            var div_hero:Array<String> = Array<String>()
            for h in pickHeroView.heroData! {
                div_hero.append(h.photo)
            }
            //TODO：客户端加入时，主机端还没有准备好数据
            MXSNetServ.shared.sendMessage(.init(type: .showHero, content: div_hero))
        case .pickHero:
            let hero_name = model.content as! String
            if let hero = MXSHeroCmd.shared.someoneFromName(hero_name) {
//                opponter = hero
//                opponter.concreteView = oppontView
//                opponter.joingame()
                
            }
            
        case .discard:
            let poker_uid_arr = model.content as! Array<Int>
            let poker_arr = MXSPokerCmd.shared.getPokersFromUids(poker_uid_arr)
            for p in poker_arr {
                p.state = .pass
            }
            passedView.collectPoker(poker_arr)
            leadingView.state = .defenseUnPick
            
        case .turnOver:
            player.signStatus = .active
            leadingView.state = .attackUnPick
        
        case .endGame:
            MXSPokerCmd.shared.packagePoker()
            MXSNetServ.shared.closeStreams()
            self.navigationController?.popViewController(animated: true)
            
        default: break
        }
    }
    
    //MARK:- leadingView
    public override func offensiveCertain() {
        leadingView.hide()
        
        let poker = player.picked.first!
        var div_p:Array<Int> = Array<Int>()
        for p in player.picked {
            div_p.append(p.uid)
        }
        MXSNetServ.shared.sendMessage(.init(type: .discard, content: div_p))
        player.ownPokers.removeAll(where: {$0 === poker})
        poker.state = .pass
        
    }
    
    public override func offensiveEndActive() {
        leadingView.hide()
        leadingView.state = .defenseUnPick
        passedView.fadeout()
        
        player.signStatus = .blank
        MXSNetServ.shared.sendMessage(.init(type: .turnOver, content: 0))
    }
    public override func defensiveCertain() {
        MXSJudge.cmd.leaderReactive()
        leadingView.hide()
    }
    
    
    //MARK:- diffrent
    
}
