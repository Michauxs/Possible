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
            MXSNetServ.shared.send([kMessageType:MessageType.showHero.rawValue, kMessageValue:div_hero])
            
        case .pickHero:
            let hero_name = dict[kMessageValue] as! String
            if let hero = MXSHeroCmd.shared.someoneFromName(hero_name) {
                opponter = hero
                opponter.concreteView = oppontView
                opponter.joingame()
                
                self.allPlayerReady()
            }
        case .endGame:
            self.dismiss(animated: true) {
                MXSPokerCmd.shared.packagePoker()
            }
        default: break
        }
    }
    
    
}
