//
//  MXSPVPCustomerController.swift
//  Possible
//
//  Created by Sunfei on 2021/5/8.
//  Copyright © 2021 boyuan. All rights reserved.
//

import UIKit

class MXSPVPCustomerController: MXSGroundController {
    var isService:Bool = false
    override func didCloseGameBtnClick() {
        MXSPokerCmd.shared.packagePoker()
        MXSNetServ.shared.send([kMessageType:MessageType.endGame.rawValue, kMessageValue:1])
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MXSNetServ.shared.send([kMessageType:MessageType.joined.rawValue, kMessageValue:1])
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func readyModelForView() {
        
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
        case .showHero:
            let names = dict[kMessageValue] as! Array<String>
            var div_hero:Array<MXSHero> = Array<MXSHero>()
            for name in names {
                if let h = MXSHeroCmd.shared.someoneFromName(name) {
                    div_hero.append(h)
                }
            }
            pickHeroView.heroData = div_hero
            
        case .pickHero:
            let hero_name = dict[kMessageValue] as! String
            if let hero = MXSHeroCmd.shared.someoneFromName(hero_name) {
                
                opponter = hero
                opponter.concreteView = oppontView
                opponter.joingame()
            }
            
        case .dealcard:
            let poker_uid_arr = dict[kMessageValue] as! Array<Int>
            var poker_arr:Array<MXSPoker> = Array<MXSPoker>()
            for uid in poker_uid_arr {
                if let p = MXSPokerCmd.shared.someoneFromUid(uid) {
                    p.state = .handOn
                    poker_arr.append(p)
                }
            }
            player.pokers.append(contentsOf: poker_arr)
            layoutPokersInBox(update: 0)
            
        case .discard:
            let poker_uid_arr = dict[kMessageValue] as! Array<Int>
            let poker_arr = MXSPokerCmd.shared.getPokersFromUids(poker_uid_arr)
            for p in poker_arr {
                p.state = .pass
            }
            passedView.collectPoker(pokers: poker_arr)
            
        case .endGame:
            self.navigationController?.popViewController(animated: true)
            
        default: break
        }
    }
    
    
    //MARK:- leadingView
    public override func certainForAttack() {
        let poker = player.pickes.first!
        player.pokers.removeAll(where: {$0 === poker})
        poker.state = .pass
        
        leadingView.isHidden = true
        player.disPokerCurrentPickes()
        layoutPokersInBox(update: 1)
        
        var div_p:Array<Int> = Array<Int>()
        for p in player.pickes {
            div_p.append(p.uid)
        }
        MXSNetServ.shared.send([kMessageType:MessageType.discard.rawValue, kMessageValue:div_p])
    }
    public override func cancelPickes() {
        for poker in player.pickes { poker.concreteView?.isUp = false }
        player.pickes.removeAll()
        MXSJudge.cmd.clearPassive()
    }
    public override func endActive() {
        leadingView.isHidden = true
        leadingView.state = .defenseUnPick
        
        MXSJudge.cmd.next()
        passedView.fadeout()
        cycleActive()
    }
    public override func certainForDefense() {
        MXSJudge.cmd.leaderReactive()
        leadingView.isHidden = true
        layoutPokersInBox(update: 1)
        
        cycleActive()
    }
    public override func cancelForDefense() {
        if player.pickes.count != 0 {
            for poker in player.pickes { poker.concreteView?.isUp = false }
            player.pickes.removeAll()
        }
        
        let action = MXSJudge.cmd.leaderActiveAction
        if action == PokerAction.attack || action == PokerAction.warFire || action == PokerAction.arrowes {
            player.minsHP()
        }
        if action == PokerAction.steal {
            let index = Int(arc4random_uniform(UInt32(player.pokers.count)))
            let poker_random = player.pokers.remove(at: index)
            opponter.pokers.append(poker_random)
            
            passedView.willCollect = false
            player.pickes.append(poker_random)
            layoutPokersInBox(update: 1)
        }
        if action == PokerAction.destroy {
            let index = Int(arc4random_uniform(UInt32(player.pokers.count)))
            let poker_random = player.pokers.remove(at: index)
            
            player.pickes.append(poker_random)
            layoutPokersInBox(update: 1)
        }
        
        MXSJudge.cmd.leaderReactive()
        leadingView.isHidden = true
        
        cycleActive()
    }
}
