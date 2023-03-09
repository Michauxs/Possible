//
//  MXSPVESoloController.swift
//  Possible
//
//  Created by Sunfei on 2021/5/7.
//  Copyright © 2021 boyuan. All rights reserved.
//

import UIKit

class MXSPVESoloController: MXSGroundController {

    override func initionalSubViewes() {
        super.initionalSubViewes()
        
        self.view.layer.contents = UIImage.init(named: "play_bg")?.cgImage
        let mask = UIView();
        mask.frame = self.view.bounds
        mask.backgroundColor = .alphaBlack
        self.view.addSubview(mask)
        self.view.sendSubview(toBack: mask)
    }
    
    override func readyModelForView() {
        
        let alert = UIAlertController.init(title: "You Wanted Count", message: "", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "x <= 7"
            textField.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: { (act) in
            self.didCloseGameBtnClick()
        }))
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (act) in
            let textField = alert.textFields![0] as UITextField
            let input:String = textField.text!
            let number:Int = Int.init(input)!
            if number <= 7 {
                
                self.numberOfChair = number+1
                
                self.view.bringSubview(toFront: self.pickHeroView)
                self.pickHeroView.showHeroOption(Data: MXSHeroCmd.shared.allHeroModel, andExpect: self.numberOfChair)
            }
            else {
                self.didCloseGameBtnClick()
            }
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    override func pickedHero(_ hero: MXSHero, chairNumb: Int = 0) {
        if chairNumb > self.heroConcreteView.count {
            return
        }
        
        hero.joingame()
        
        let concreteView = self.heroConcreteView[chairNumb-1]
        hero.concreteView = concreteView
        
        if chairNumb == 1 {
            player = hero
            player.isAxle = true
            
            player.pokersView = graspPokerView;
        }
        
        if chairNumb == self.numberOfChair {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(750)) {
                self.allHeroReady()
            }
        }
    }
    
    func allHeroReady() {
        if MXSPokerCmd.shared.shuffle() {
            
            MXSJudge.cmd.dealcardForGameStart()
            MXSJudge.cmd.dealcardForNextLeader { hero, pokers in
                if hero.isAxle {
                    leadingView.state = .attackUnPick
                }
                else {
                    AITurnToAttack()
                }
            }
        }
        else {
            MXSLog("shuffle poker failed")
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
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(750)) {
            self.asyncAfterSecondWaitingResponerReply()
        }
    }
    func asyncAfterSecondWaitingResponerReply() {
        guard let replyer = MXSJudge.cmd.responder.first else {
            MXSJudge.cmd.leaderReactive()
            
            if MXSJudge.cmd.leader!.isAxle {
                leadingView.state = .attackUnPick
            }
            else {
                AITurnToAttack()
            }
            return
        }
        
        //reply action : single/group
        replyer.makeOneReplyAction()
        if replyer.isAxle {
            leadingView.state = .defenseUnPick
        }
        else {
            replyer.asReplyerParryAttack(reBlock: { type, pokers in
                
                if type == .failed {
                    let hasDefault = MXSJudge.cmd.responderSufferConsequence { spoils, pokers in
                        if spoils == .destroy {
                            passedView.collectPoker(pokers!)
                        }
                        else if spoils == .wrest {
                            
                        }
                        else if spoils == .injured {
                            if replyer.HPCurrent == 0 {
                                return
                            }
                        }
                        MXSLog("step done")
                    }
                    
                    if hasDefault == false {
                        MXSJudge.cmd.oneByOneReplyGroup()
                        MXSLog("one opponter done -> goon")
                        
                        waitingResponerReply()
                    }
                }
                else if type == .success {
                    passedView.collectPoker(pokers!)
                    
                    MXSJudge.cmd.oneByOneReplyGroup()
                    MXSLog("one opponter done -> goon")
                    
                    waitingResponerReply()
                }
                
            })
        }
    }
    
    override func endLeaderCycle() {
        MXSJudge.cmd.dealcardForNextLeader { hero, pokers in
            
        }
        AITurnToAttack()
    }
    
    override func playerReplyAsResponder() {
        let responder = MXSJudge.cmd.responder.first
        let _ = responder?.discardPoker(reBlock: { type, poker in
            if type == .passed {
                MXSLog(poker, "player discard poker")
                passedView.collectPoker(poker)
            }
            else if type == .handover {// = active give + responder gain
                //TODO: - animate P->P
            }
        })
        
        MXSJudge.cmd.leaderReactive()
        AITurnToAttack()
    }
    func AITurnToAttack() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(750)) {
            self.asyncAfterSecondAICantAttack()
        }
    }
    func asyncAfterSecondAICantAttack() {
        let leader = MXSJudge.cmd.leader!
        if leader.hasPokerDoAttack(reBlock: { has, pokers, skill in
            if has {
                leader.pickPoker(pokers!.first!)
                let waiting = leader.discardPoker(reBlock: { type, poker in
                    
                    if type == .passed {
                        passedView.collectPoker(poker)
                    }
                    else if type == .handover {
                        // TODO: - animate P->P
                    }
                })
                
                if waiting {
                    waitingResponerReply()
                }
                else {
                    AITurnToAttack()
                }
                
            }
        }) {
            //nothing todo
        }
        else {
            AICantAttack()
        }
        
    }
    
    
    func AICantAttack() {
        MXSLog("AI cant attack")
        passedView.fadeout()
        
        MXSJudge.cmd.dealcardForNextLeader { hero, pokers in
            
            if hero.isAxle { leadingView.state = .attackUnPick }
            else {
                AITurnToAttack()
            }
        }
    }
    
    override func playerDidntReply() {
        
        let hasDefault = MXSJudge.cmd.responderSufferConsequence { spoils, pokers in
            if spoils == .destroy {
                passedView.collectPoker(pokers!)
            }
            else if spoils == .wrest {
                
            }
            else if spoils == .injured {
                if player.HPCurrent == 0 {
                    return
                }
            }
        }
        
        if hasDefault == false {
            MXSJudge.cmd.oneByOneReplyGroup()
            self.waitingResponerReply()
        }
    }
    
    
    // MARK: - hero
    
    
    // MARK: - application
    override var prefersStatusBarHidden: Bool {
        return true
    }

}
