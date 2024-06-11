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
        pickHeroView.heroData = MXSHeroCmd.shared.allHeroModel
    }
    
    override func pickedHero(_ hero: MXSHero, chairNumb: Int = 0) {
        player = hero
        player.isAxle = true
        player.concreteView = playerView
        
        player.joingame()
        pickHeroView.isHidden = true
        MXSNetServ.shared.sendMessage(.init(type: .pickHero, content: hero.photo))
        
        self.allPlayerReady()
    }
    
    func allPlayerReady() {
//        if player.name == kStringUnknown || opponter.name == kStringUnknown {
//            return
//        }
        if MXSPokerCmd.shared.shuffle() {
            let pokers = MXSPokerCmd.shared.push(6)
            player.getPokers(pokers)
            player.GraspView?.collectPoker(pokers)
            player.concreteView?.getPokerAnimate(pokers, complete: {
                self.player.concreteView?.pokerCount = self.player.ownPokers.count
            })
            
            
            let arr_p = MXSPokerCmd.shared.push(6)
            
            var poker_uid_arr:Array<Int> = Array<Int>()
            for poker in arr_p {
                poker_uid_arr.append(poker.uid)
            }
            MXSNetServ.shared.sendMessage(.init(type: .dealcard, content: poker_uid_arr))
            
            player.signStatus = .active
            leadingView.state = .attackUnPick
        }
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
                
                self.allPlayerReady()
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
    
    
}
