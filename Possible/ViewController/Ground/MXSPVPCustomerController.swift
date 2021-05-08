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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MXSNetServ.shared.send([kMessageType:MessageType.joined.rawValue, kMessageValue:1])
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func readyModelForView() {
        
    }
    
    override func pickedHero(_ hero: MXSHero) {
        player = hero
        player.isAxle = true
        player.concreteView = playerView
        
        player.joingame()
        pickHeroView.isHidden = true
    }
    
    override func havesomeMessage(_ dict: Dictionary<String, Any>) {
        super.havesomeMessage(dict)
        
        let type:MessageType = MessageType.init(rawValue: dict[kMessageType] as! Int)!
        switch type {
        case .showHero:
            let data_hero = dict[kMessageValue] as! Array<MXSHero>
            pickHeroView.heroData = data_hero
            
        case .pickHero:
            let hero = dict[kMessageValue] as! MXSHero
            opponter = hero
            opponter.concreteView = oppontView
            opponter.joingame()
            
        case .dealcard:
            let data_poker = dict[kMessageValue] as! Array<MXSPoker>
            player.pokers.append(contentsOf: data_poker)
            layoutPokersInBox(update: 0)
            
        default: break
        }
    }
}
