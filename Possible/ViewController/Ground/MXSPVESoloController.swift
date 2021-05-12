//
//  MXSPVESoloController.swift
//  Possible
//
//  Created by Sunfei on 2021/5/7.
//  Copyright © 2021 boyuan. All rights reserved.
//

import UIKit

class MXSPVESoloController: MXSGroundController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func readyModelForView() {
        pickHeroView.heroData = MXSHeroCmd.shared.allHeroModel()
    }
    
    override func pickedHero(_ hero: MXSHero, isOpponter:Bool = false) {
        if isOpponter {
            opponter = hero
            opponter.concreteView = oppontView
            
            if MXSPokerCmd.shared.shuffle() {
                player.pokers.append(contentsOf: MXSPokerCmd.shared.push(6))
                layoutPokersInBox(update: 0)
                opponter.pokers.append(contentsOf: MXSPokerCmd.shared.push(6))
            }
            opponter.joingame()
            /*--------------------------------------------*/
            
            let btn_height:CGFloat = 40.0
            var height_sum:CGFloat = 5.0
            for skill in player.skillSet {
                if skill.power == .blank || skill.power == .unKnown || skill.power == .lock { continue }
                let btn = MXSSkillBtn.init(skill:skill)
                btn.frame = CGRect(x: 5, y: height_sum, width: skillScrollView.frame.width-10.0, height: btn_height)
                skillScrollView.addSubview(btn)
                height_sum += btn_height+3
                btn.addTarget(self, action: #selector(didSkillBtnClick(btn:)), for: .touchUpInside)
            }
            skillScrollView.contentSize = CGSize.init(width: 0, height: height_sum)
            
            pickHeroView.isHidden = true
            cycleActive()
        }
        else {
            player = hero
            player.isAxle = true
            player.concreteView = playerView
            
            player.joingame()
            MXSNetServ.shared.send([kMessageType:MessageType.pickHero.rawValue, kMessageValue:hero.photo])
            
        }
        
    }

}
