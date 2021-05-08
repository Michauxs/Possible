//
//  MXSPVPServiceController.swift
//  Possible
//
//  Created by Sunfei on 2021/5/8.
//  Copyright © 2021 boyuan. All rights reserved.
//

import UIKit

class MXSPVPServiceController: MXSGroundController {
    var isService:Bool = false

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func readyModelForView() {
        pickHeroView.heroData = MXSHeroCmd.shared.allHeroModel()
    }
    
    override func pickedHero(_ hero: MXSHero) {
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
            print("some one joined game")
            MXSNetServ.shared.send([kMessageType:MessageType.showHero.rawValue, kMessageValue:pickHeroView.heroData])
            
        case .pickHero:
            let hero_photo = dict[kMessageValue] as! String
            let hero = MXSHeroCmd.shared.someoneFromName(hero_photo)
            opponter = hero
            opponter.concreteView = oppontView
            opponter.joingame()
            
            if MXSPokerCmd.shared.shuffle() {
                player.pokers.append(contentsOf: MXSPokerCmd.shared.push(6))
                layoutPokersInBox(update: 0)
                
                let arr_p = MXSPokerCmd.shared.push(6)
                opponter.pokers.append(contentsOf: arr_p)
                MXSNetServ.shared.send([kMessageType:MessageType.dealcard.rawValue, kMessageValue:arr_p])
            }
        default: break
        }
    }
}
