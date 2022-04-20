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
    }
    
    override func readyModelForView() {
        pickHeroView.heroData = MXSHeroCmd.shared.allHeroModel
    }
    
    override func pickedHero(_ hero: MXSHero, isOpponter:Bool = false) {
        if isOpponter {
            opponter = hero
            opponter.concreteView = oppontView
            opponter.joingame()
            
            allHeroReady()
        }
        else {
            player = hero
            player.joingame()
            player.isAxle = true
            player.concreteView = playerView
        }
    }
    func allHeroReady() {
        if MXSPokerCmd.shared.shuffle() {
            let pokers = MXSPokerCmd.shared.push(6)
            player.getPoker(pokers)
            pokerScrollView!.appendPoker(pokers: pokers)
            
            let pokers_o = MXSPokerCmd.shared.push(6)
            opponter.getPoker(pokers_o)
        }
        
        MXSJudge.cmd.leader = player
        leadingView.isHidden = false
    }

    // MARK: - Skill
    @objc override func didSkillBtnClick(btn:MXSSkillBtn) {
//        btn.isSelected = !btn.isSelected
        print(btn.power as Any)
        if btn.isSelected {
            player.stopSkill(btn.belong!)
        } else {
            player.startingSkill(btn.belong!)
        }
        checkCanCertainAction()
    }
    
    // MARK: - leadingView
    override func updateViewsWaitOpponterRespon() {
        MXSJudge.cmd.responderReplyAction { can, pokers in
            if !can {
                MXSJudge.cmd.responderSufferConsequence { spoils, pokers in
                    if spoils == .destroy {
                        passedView.collectPoker(pokers: pokers!)
                    }
                    else if spoils == .wrest {
                        pokerScrollView!.appendPoker(pokers: pokers!)
                    }
                    print("step done")
                }
            }
            else {
                opponter.losePoker(pokers!)
                passedView.collectPoker(pokers: pokers!)
            }
            
            MXSJudge.cmd.leaderReactive()
            leadingView.isHidden = false
            leadingView.state = .attackUnPick
            print("opponter done -> goon")
        }
    }
    
    override func endLeaderCycle() {
        afterLeaderReactive()
    }
    
    override func responderReply() {
        
        pokerScrollView!.removePoker(pokers: player.pickes)
        passedView.collectPoker(pokers: player.pickes)
        let responder = MXSJudge.cmd.responder.first
        responder?.discardPoker()
        
        MXSJudge.cmd.leaderReactive()
        afterLeaderReactive()
    }
    func afterLeaderReactive() {
        let hero = MXSJudge.cmd.leader!
        hero.choiceResponder()
        hero.hasPokerDoAttack { has, pokers, skill in
            if has {
                hero.pickPoker(pokers!.first!)
                
                passedView.collectPoker(pokers: pokers!)
                MXSJudge.cmd.leader?.discardPoker()
                
                leadingView.isHidden = false
                leadingView.state = .defenseUnPick
                
                let responder = MXSJudge.cmd.responder.first
                responder?.makeOneReplyAction()
            }
            else {
                passedView.fadeout()
                MXSJudge.cmd.next()
                
                let pokers = MXSPokerCmd.shared.push(MXSJudge.cmd.leader!.collectNumb)
                MXSJudge.cmd.leader!.getPoker(pokers)
                pokerScrollView!.appendPoker(pokers: pokers)
                
                leadingView.isHidden = false
                leadingView.state = .attackUnPick
            }
        }
    }
    
    override func responderCantReply() {
        afterLeaderReactive()
    }
    
    
    // MARK: - hero
    
    
    // MARK: - application
    override var prefersStatusBarHidden: Bool {
        return true
    }

}
