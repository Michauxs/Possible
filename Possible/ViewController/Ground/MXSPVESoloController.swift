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
            
            player.oneGraspPokerView = graspPokerView;
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
    override func checkResponderAndWaitReply() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(750)) {
            self.asyncAfterSecondWaitingResponerReply()
        }
    }
    func asyncAfterSecondWaitingResponerReply() {
        guard let replyer = MXSJudge.cmd.pleaseResponderReply() else {
            // no one reply / all reply done
            MXSJudge.cmd.leaderReactive()
            
            if MXSJudge.cmd.leader!.isAxle {
                leadingView.state = .attackUnPick
            }
            else {
                AITurnToAttack()
            }
            return
        }
        
//        if let replyer = MXSJudge.cmd.pleaseResponderReply() { }
        replyer.asReplyerParryAttack(reBlock: { type, pokers in
            if type == .failed {
                let hasFailed = MXSJudge.cmd.responderSufferConsequence { spoils, pokers in
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
                }
            }
            else if type == .success {
                passedView.collectPoker(pokers!)
            }
            else if type == .nothing {
                
            }
            else if type == .gain {
                
            }
            else if type == .operate {
                leadingView.state = .defenseUnPick
                MXSLog("there need Return")
                return
            }
            
            MXSLog("step done")
            MXSJudge.cmd.oneByOneReplyGroup()
            checkResponderAndWaitReply()
        })
        
    }
    
    override func endLeaderCycle() {
        MXSJudge.cmd.dealcardForNextLeader { hero, pokers in
            
        }
        AITurnToAttack()
    }
    
    override func playerReplyAsResponder() {
        let responder = MXSJudge.cmd.responder.first
        responder?.discardPoker(reBlock: { needWaiting, type, poker in
            if type == .passed {
                MXSLog(poker, "player discard poker")
                passedView.collectPoker(poker)
            }
            else if type == .handover {// = active give + responder gain
                //TODO: - animate P->P
            }
        })
        
//        MXSJudge.cmd.leaderReactive()
//        AITurnToAttack()
        
        MXSJudge.cmd.oneByOneReplyGroup()
        checkResponderAndWaitReply()
    }
    func AITurnToAttack() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(750)) {
            self.asyncAfterSecondAICantAttack()
        }
    }
    func asyncAfterSecondAICantAttack() {
        let leader = MXSJudge.cmd.leader!
        leader.hasPokerDoAttack(reBlock: { has, pokers, skill in
            if has {
                leader.pickPoker(pokers!.first!)
                leader.discardPoker(reBlock: { needWaiting, type, poker in
                    
                    if type == .passed {
                        passedView.collectPoker(poker)
                    }
                    else if type == .handover {
                        // TODO: - animate P->P
                    }
                    
                    if needWaiting {
                        checkResponderAndWaitReply()
                    }
                    else {
                        AITurnToAttack()
                    }
                })
            }
            else {
                AICantAttack()
            }
        })
        
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
                //let pok_view = MXSPokerView()
            }
            else if spoils == .injured {
                if player.HPCurrent == 0 {
                    return
                }
            }
        }
        
        if hasDefault == false {
            MXSJudge.cmd.oneByOneReplyGroup()
            self.checkResponderAndWaitReply()
        }
    }
    
    
    // MARK: - hero
    
    
    // MARK: - application
    override var prefersStatusBarHidden: Bool {
        return true
    }

}
