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
            
//            printPointer(ptr: &pokers.first, "pokers.0")
//            MXSLog(Unmanaged.passRetained(pokers.first as AnyObject), "pokers.0")
            MXSLog(pokers)
            
            player.getPoker(pokers)
            graspPokerView!.appendPoker(pokers: pokers)
            
            let pokers_o = MXSPokerCmd.shared.push(6)
            opponter.getPoker(pokers_o)
        }
        
        MXSJudge.cmd.leader = player
        leadingView.isHidden = false
    }

    // MARK: - Skill
    @objc override func didSkillBtnClick(btn:MXSSkillBtn) {
//        btn.isSelected = !btn.isSelected
        MXSLog(btn.power as Any)
        if btn.isSelected {
            player.stopSkill(btn.belong!)
        } else {
            player.startingSkill(btn.belong!)
        }
        checkCanCertainAction()
    }
    
    // MARK: - leadingView
    override func waitingResponerReply() {
        MXSJudge.cmd.responderReplyAction { type, pokers in
            if type == .failed {
                MXSJudge.cmd.responderSufferConsequence { spoils, pokers in
                    if spoils == .destroy {
                        passedView.collectPoker(pokers!)
                    }
                    else if spoils == .wrest {
                        graspPokerView!.appendPoker(pokers: pokers!)
                    }
                    MXSLog("step done")
                }
            }
            else if type == .success {
                passedView.collectPoker(pokers!)
            }
            
            MXSJudge.cmd.leaderReactive()
            
            leadingView.isHidden = false
            leadingView.state = .attackUnPick
            MXSLog("opponter done -> goon")
        }
    }
    
    override func endLeaderCycle() {
        afterLeaderReactive()
    }
    
    override func responderReply() {
        
        let responder = MXSJudge.cmd.responder.first
        responder?.discardPoker(reBlock: { type, poker in
            graspPokerView!.removePoker(poker)
            if type == .passed {
                passedView.collectPoker(poker)
            }
            else if type == .handover {
//                MXSJudge.cmd.responder.first?.getPoker(poker)
            }
        })
        
        MXSJudge.cmd.leaderReactive()
        afterLeaderReactive()
    }
    func afterLeaderReactive() {
        //opponter lead
        let hero = MXSJudge.cmd.leader!
        hero.choiceResponder()
        hero.hasPokerDoAttack { has, pokers, skill in
            if has {
                hero.pickPoker(pokers!.first!)
                hero.discardPoker(reBlock: { type, poker in
                    if type == .passed {
                        passedView.collectPoker(poker)
                    }
                    else if type == .handover {
                        MXSJudge.cmd.responder.first?.getPoker(poker)
                        graspPokerView?.appendPoker(pokers: poker)
                    }
                })
                
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
                graspPokerView!.appendPoker(pokers: pokers)
                
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
