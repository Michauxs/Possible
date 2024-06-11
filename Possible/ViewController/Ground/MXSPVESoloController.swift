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
            
            player.GraspView = self.graspPokerView;
            player.leadingView = self.leadingView
        }
        
        if chairNumb == self.numberOfChair {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(750)) {
                self.allHeroReady()
            }
        }
    }
    
    func allHeroReady() {
        if MXSPokerCmd.shared.shuffle() {
            
            MXSJudge.cmd.dealcardForGameStart { hero in
                if hero.isAxle {
                    leadingView.state = .attackUnPick
                }
                else {
                    turnToAIAttack()
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
            self.responerReplyAfterFewSecond()
        }
    }
    func responerReplyAfterFewSecond() {
        guard let responder = MXSJudge.cmd.pleaseResponderReply() else {
            // no one reply / all reply done
            MXSJudge.cmd.leaderReactive()
            
            if MXSJudge.cmd.leader!.isAxle {
                leadingView.state = .attackUnPick
            }
            else { turnToAIAttack() }
            return
        }
        
        responder.parryAttack { parry, pokers, pokerWay in
            if parry == .recover { }
            else if parry == .unneed { }
            else if parry == .receive {
                
                responder.GraspView?.collectPoker(pokers!)
                responder.concreteView?.getPokerAnimate(pokers!, complete: {
                    responder.concreteView?.pokerCount = responder.ownPokers.count
                })
            }
            else if parry == .mismatch {
                MXSJudge.cmd.responderSufferConsequence { spoils, pokers, pokerWay in
                    if spoils == .destroy {
                        passedView.collectPoker(pokers!)
                    }
                    else if spoils == .wrest {
                        self.pokerHandover(from: responder, to: MXSJudge.cmd.leader!) {
                            MXSLog("poker handvoer complete")
                        }
                    }
                    else if spoils == .injured {
                        if responder.HPCurrent <= 0 {
                            MXSLog("there need Return")
                            return
                        }
                    }
                }
            }
            else if parry == .answered {
                passedView.collectPoker(pokers!)
            }
            else if parry == .operate {
                leadingView.state = .defenseUnPick
                MXSLog("there need Return")
                return
            }
            
            MXSLog("step done")
            MXSJudge.cmd.responderHaveReplyed()
            checkResponderAndWaitReply()
        }
        
    }
    
    
    
    override func offensiveEndActiveSubject() {
        player.endCurrentCycle { hero in
            self.turnToAIAttack()
        }
    }
    
    override func defensiveCertainSubject() {
        
        let responder = MXSJudge.cmd.responder.first
        responder?.discardPoker(reBlock: { needWaiting, type, pokeres in
            if type == .passed {
                MXSLog(pokeres, "player discard poker")
                graspPokerView.losePokerView(pokeres) {
                    self.passedView.collectPoker(pokeres)
                }
            }
            else if type == .awayfrom {// = active give + responder gain
                //TODO : -- animate P->P
                self.pokerHandover(from: responder!, to: MXSJudge.cmd.leader!) {
                    
                }
            }
        })
        
//        MXSJudge.cmd.leaderReactive()
//        AITurnToAttack()
        
        MXSJudge.cmd.responderHaveReplyed()
        checkResponderAndWaitReply()
    }
    func turnToAIAttack() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(750)) {
            self.AIDoActionAfterFewSecond()
        }
    }
    func AIDoActionAfterFewSecond() {
        let leader = MXSJudge.cmd.leader!
        leader.hasPokerDoAttack(reBlock: { has, pokers, skill in
            if has {
                leader.pickPoker(pokers!.first!)
                leader.discardPoker(reBlock: { needWaiting, type, pokeres in
                    
                    if type == .passed {
                        passedView.collectPoker(pokeres)
                    }
                    else if type == .awayfrom {
                        // TODO: - animate P->P
                    }
                    
                    if needWaiting {
                        checkResponderAndWaitReply()
                    }
                    else {
                        turnToAIAttack()
                    }
                })
            }
            else {
                MXSLog("AI cant attack")
                passedView.fadeout()
                leader.endCurrentCycle { hero in
                    if hero.isAxle {
                        self.leadingView.state = .attackUnPick
                    }
                    else {
                        self.turnToAIAttack()
                    }
                }
            }
                
        })
    }
    
    override func defensiveCancelSubject() {
        
        MXSJudge.cmd.responderSufferConsequence { spoils, pokers, pokerWay in
            
            if spoils == .destroy {
                player.GraspView?.losePokerView(pokers!, complete: {
                    self.passedView.collectPoker(pokers!)
                })
            }
            else if spoils == .wrest {
                player.GraspView?.losePokerView(pokers!, complete: {
                    self.pokerHandover(from: self.player, to: MXSJudge.cmd.leader!) {
                        MXSLog("poker handvoer complete")
                    }
                })
            }
            else if spoils == .injured {
                if player.HPCurrent <= 0 {
                    return
                }
                else {
                    
                }
            }
            
            MXSJudge.cmd.responderHaveReplyed()
            self.checkResponderAndWaitReply()
        }
    }
    
    
    // MARK: - hero
    
    
    
    // MARK: - application
    override var prefersStatusBarHidden: Bool {
        return true
    }

}
