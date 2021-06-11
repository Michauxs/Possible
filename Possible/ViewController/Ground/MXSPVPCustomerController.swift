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
            
        case .endGame:
            self.navigationController?.popViewController(animated: true)
            
        default: break
        }
    }
}
