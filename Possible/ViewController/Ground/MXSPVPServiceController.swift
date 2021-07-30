//
//  MXSPVPServiceController.swift
//  Possible
//
//  Created by Sunfei on 2021/5/8.
//  Copyright © 2021 boyuan. All rights reserved.
//

import UIKit

class MXSPVPServiceController: MXSPVPController {

    override func readyModelForView() {
        pickHeroView.heroData = MXSHeroCmd.shared.allHeroModel()
    }
    
    override func pickedHero(_ hero: MXSHero, isOpponter:Bool = false) {
        player = hero
        player.isAxle = true
        player.concreteView = playerView
        
        player.joingame()
        pickHeroView.isHidden = true
        MXSNetServ.shared.send([kMessageType:MessageType.pickHero.rawValue, kMessageValue:hero.photo])
        
        self.allPlayerReady()
    }
    
    func allPlayerReady() {
        if player.name == "Unknown" || opponter.name == "Unknown" {
            return
        }
        if MXSPokerCmd.shared.shuffle() {
            player.pokers.append(contentsOf: MXSPokerCmd.shared.push(6))
            layoutPokersInBox(update: 0)
            
            let arr_p = MXSPokerCmd.shared.push(6)
            opponter.pokers.append(contentsOf: arr_p)
            var poker_uid_arr:Array<Int> = Array<Int>()
            for poker in arr_p {
                poker_uid_arr.append(poker.uid)
            }
            MXSNetServ.shared.send([kMessageType:MessageType.dealcard.rawValue, kMessageValue:poker_uid_arr])
            
            player.signStatus = .active
            leadingView.state = .attackUnPick
        }
    }
    
    override func havesomeMessage(_ dict: Dictionary<String, Any>) {
        super.havesomeMessage(dict)
        
        let type:MessageType = MessageType.init(rawValue: dict[kMessageType] as! Int)!
        switch type {
        case .joined:
            print("some one joined game")
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
                
                self.allPlayerReady()
            }
            
        case .discard:
            let poker_uid_arr = dict[kMessageValue] as! Array<Int>
            let poker_arr = MXSPokerCmd.shared.getPokersFromUids(poker_uid_arr)
            for p in poker_arr {
                p.state = .pass
            }
            passedView.collectPoker(pokers: poker_arr)
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
        print("controller action hero")
        if player.signStatus != .active {
            return
        }
        guard let hero = heroView.belong else {
            return
        }
        
        if hero.signStatus == .selected {
            hero.signStatus = .blank
            MXSJudge.cmd.removePassive(hero)
        }
        else {
            hero.signStatus = .selected
            MXSJudge.cmd.addPassive(hero)
        }
        checkCanCertainAction()
    }
    
    //MARK:- poker
    @objc public override func someonePokerTaped(_ pokerView: MXSPokerView) {
        if let index = player.pokers.firstIndex(where: {$0 === pokerView.belong}) {
            print("controller action pok at " + "\(index)")
        }
        
        pokerView.isUp = !pokerView.isUp
        if player.signStatus != .active {
            return
        }
        
        let poker = pokerView.belong!
        if pokerView.isUp {
            player.pickPoker(poker)
        } else {
            player.disPickPoker(poker)
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
        player.disPokerCurrentPickes()
        layoutPokersInBox(update: 1)
        
    }
    public override func cancelPickes() {
        for poker in player.pickes { poker.isPicked = false }
        player.pickes.removeAll()
        MXSJudge.cmd.clearPassive()
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
