//
//  MXSPVPSoloController.swift
//  Possible
//
//  Created by Sunfei on 2021/5/7.
//  Copyright © 2021 boyuan. All rights reserved.
//

import UIKit

class MXSPVPSoloController: MXSGroundController {
    var isService:Bool = false

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MXSNetServ.shared.send([kMessageType:MessageType.joined.rawValue, kMessageValue:1])
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func readyModelForView() {
        pickHeroView.heroData = MXSHeroCmd.shared.allHeroModel()
    }

    override func havesomeMessage(_ dict: Dictionary<String, Any>) {
        super.havesomeMessage(dict)
        
        let type:MessageType = MessageType.init(rawValue: dict[kMessageType] as! Int)!
        switch type {
        case .joined:
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
