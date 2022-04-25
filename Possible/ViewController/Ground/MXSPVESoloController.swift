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
            player.pokersView = graspPokerView;
//            graspPokerView?.belong = player
        }
    }
    func allHeroReady() {
        if MXSPokerCmd.shared.shuffle() {
            
            MXSJudge.cmd.dealcardForGameStart()
            MXSJudge.cmd.dealcardForNextLeader { hero, pokers in
                
            }
            leadingView.state = .attackUnPick
        }
        else {
            didCloseGameBtnClick()
        }
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
        MXSJudge.cmd.AIReplyAsResponder { type, pokers in
            if type == .failed {
                MXSJudge.cmd.responderSufferConsequence { spoils, pokers in
                    if spoils == .destroy {
                        passedView.collectPoker(pokers!)
                    }
                    else if spoils == .wrest {
                        
                    }
                    MXSLog("step done")
                }
            }
            else if type == .success {
                passedView.collectPoker(pokers!)
            }
            
            MXSJudge.cmd.leaderReactive()
            
            leadingView.state = .attackUnPick
            MXSLog("opponter done -> goon")
        }
    }
    
    override func endLeaderCycle() {
        MXSJudge.cmd.dealcardForNextLeader { hero, pokers in
            
        }
        waitingAIAttack()
    }
    
    override func playerReplyAsResponder() {
        
        let responder = MXSJudge.cmd.responder.first
        let _ = responder?.discardPoker(reBlock: { type, poker in
            if type == .passed {
                MXSLog(poker, "player discard poker")
                
                passedView.collectPoker(poker)
            }
            else if type == .handover {// = active give + responder gain
                
                //TODO: animate P->P
            }
        })
        
        MXSJudge.cmd.leaderReactive()
        waitingAIAttack()
    }
    func waitingAIAttack() {
        //opponter lead
        let leader = MXSJudge.cmd.leader!
        leader.hasPokerDoAttack { has, pokers, skill in
            if has {
                leader.pickPoker(pokers!.first!)
                let waiting = leader.discardPoker(reBlock: { type, poker in
                    if leader.holdAction?.action == .warFire || leader.holdAction?.action == .arrowes {
                        MXSJudge.cmd.selectAllElseSelf()
                    }
                    if type == .passed {
                        passedView.collectPoker(poker)
                    }
                    else if type == .handover {
                        MXSJudge.cmd.responder.first?.getPokers(poker)
                        
                    }
                })
                
                if waiting {
                    leadingView.state = .defenseUnPick
                    //reply action
                    let responder = MXSJudge.cmd.responder.first
                    responder?.makeOneReplyAction()
                }
                else {
                    waitingAIAttack()
                }
                    
            }
            else {
                AICantAttack()
            }
        } //block
    }
    func AICantAttack() {
        MXSLog("AI cant attack")
        passedView.fadeout()
        leadingView.state = .attackUnPick
        
        MXSJudge.cmd.dealcardForNextLeader { hero, pokers in
            
        }
    }
    
    override func responderCantReply() {
        waitingAIAttack()
    }
    
    
    // MARK: - hero
    
    
    // MARK: - application
    override var prefersStatusBarHidden: Bool {
        return true
    }

}
