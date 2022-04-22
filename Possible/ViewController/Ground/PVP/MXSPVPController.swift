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
        MXSNetServ.shared.send([kMessageType:MessageType.endGame.rawValue, kMessageValue:1])
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
    
    override func pickedHero(_ hero: MXSHero, isOpponter:Bool = false) {
        player = hero
        player.isAxle = true
        player.concreteView = playerView
        
        player.joingame()
        pickHeroView.isHidden = true
        MXSNetServ.shared.send([kMessageType:MessageType.pickHero.rawValue, kMessageValue:hero.photo])
        
    }
    
    override func havesomeMessage(_ dict: Dictionary<String, Any>) {
        super.havesomeMessage(dict)
        
        let type:MessageType = MessageType.init(rawValue: dict[kMessageType] as! Int)!
        switch type {
        case .joined:
            MXSLog("some one joined game")
            var div_hero:Array<String> = Array<String>()
            for h in pickHeroView.heroData! {
                div_hero.append(h.photo)
            }
            //TODO：客户端加入时，主机端还没有准备好数据
            MXSNetServ.shared.send([kMessageType:MessageType.showHero.rawValue, kMessageValue:div_hero])
            
        case .pickHero:
            let hero_name = dict[kMessageValue] as! String
            if let hero = MXSHeroCmd.shared.someoneFromName(hero_name) {
                opponter = hero
                opponter.concreteView = oppontView
                opponter.joingame()
                
            }
            
        case .discard:
            let poker_uid_arr = dict[kMessageValue] as! Array<Int>
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
    
    //MARK:- hero
    public override func someoneHeroTaped(_ heroView: MXSHeroView) {
        MXSLog("controller action hero")
        if player.signStatus != .active {
            return
        }
        guard let hero = heroView.belong else {
            return
        }
        
        if hero.signStatus == .selected {
            hero.signStatus = .blank
            MXSJudge.cmd.leader?.takeOrDisAimAtHero(hero)
        }
        else {
            hero.signStatus = .selected
            MXSJudge.cmd.leader?.takeOrDisAimAtHero(hero)
        }
        checkCanCertainAction()
    }
    
    //MARK:- poker
    @objc public override func someonePokerTaped(_ pokerView: MXSPokerView) {
        if let index = player.pokers.firstIndex(where: {$0 === pokerView.belong}) {
            MXSLog("controller action pok at " + "\(index)")
        }
        
        pokerView.isUp = !pokerView.isUp
        if player.signStatus != .active {
            return
        }
        
        let poker = pokerView.belong!
        if pokerView.isUp {
            player.pickPoker(poker)
        } else {
            player.freePoker(poker)
        }
        
        checkCanCertainAction()
    }
    
    //MARK:- leadingView
    public override func certainForAttack() {
        let poker = player.pickes.first!
        var div_p:Array<Int> = Array<Int>()
        for p in player.pickes {
            div_p.append(p.uid)
        }
        MXSNetServ.shared.send([kMessageType:MessageType.discard.rawValue, kMessageValue:div_p])
        
        player.pokers.removeAll(where: {$0 === poker})
        poker.state = .pass
        
        leadingView.isHidden = true
        
    }
    
    public override func endActive() {
        leadingView.isHidden = true
        leadingView.state = .defenseUnPick
        passedView.fadeout()
        
        player.signStatus = .blank
        MXSNetServ.shared.send([kMessageType:MessageType.turnOver.rawValue, kMessageValue:0])
    }
    public override func certainForDefense() {
        MXSJudge.cmd.leaderReactive()
        leadingView.isHidden = true
    }
    
    
    //MARK:- diffrent
    
}
