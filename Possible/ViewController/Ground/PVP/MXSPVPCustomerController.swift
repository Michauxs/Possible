//
//  MXSPVPCustomerController.swift
//  Possible
//
//  Created by Sunfei on 2021/5/8.
//  Copyright © 2021 boyuan. All rights reserved.
//

import UIKit

class MXSPVPCustomerController: MXSPVPController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MXSNetServ.shared.sendMessage(.init(type: .joined, content: 1))
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
        case .showHero:
            let names = model.content as! Array<String>
            var div_hero:Array<MXSHero> = Array<MXSHero>()
            for name in names {
                if let h = MXSHeroCmd.shared.someoneFromName(name) {
                    div_hero.append(h)
                }
            }
            pickHeroView.heroData = div_hero
            
        case .pickHero:
            let hero_name = model.content as! String
            if let hero = MXSHeroCmd.shared.someoneFromName(hero_name) {
                
//                opponter = hero
//                opponter.concreteView = oppontView
//                opponter.joingame()
            }
            
        case .dealcard:
            let poker_uid_arr = model.content as! Array<Int>
            var pokers:Array<MXSPoker> = Array<MXSPoker>()
            for uid in poker_uid_arr {
                if let p = MXSPokerCmd.shared.someoneFromUid(uid) {
                    p.state = .handOn
                    pokers.append(p)
                }
            }
            player.getPokers(pokers)
            player.GraspView?.collectPoker(pokers)
            player.concreteView?.getPokerAnimate(pokers, complete: {
                self.player.concreteView?.pokerCount = self.player.ownPokers.count
            })
            
            
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
            MXSNetServ.shared.closeStreams()
            self.navigationController?.popViewController(animated: false)
            
        default: break
        }
    }
    
    //MARK:- leadingView
    
}
