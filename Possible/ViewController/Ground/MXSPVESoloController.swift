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
            
            player.oneGraspPokerView = self.graspPokerView;
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
        guard let replyer = MXSJudge.cmd.pleaseResponderReply() else {
            // no one reply / all reply done
            MXSJudge.cmd.leaderReactive()
            
            if MXSJudge.cmd.leader!.isAxle {
                leadingView.state = .attackUnPick
            }
            else { turnToAIAttack() }
            return
        }
        
        if MXSJudge.cmd.leader!.isAxle {
            replyer.parryAttack { parry, pokers, pokerWay in
                if parry == .recover { }
                else if parry == .gain { }
                else if parry == .operate {
                    leadingView.state = .defenseUnPick
                    MXSLog("there need Return")
                    return
                }
                
                MXSLog("step done")
                MXSJudge.cmd.theHeroHasReplyed()
                checkResponderAndWaitReply()
            }
        }
        else {
            replyer.AIParryAttack { parry, pokers, pokerWay in
                self.defensiverParryAttack(hero:replyer, parry: parry, pokers: pokers, pokerWay: pokerWay)
            }
        }
    }
    
    var playerParryAttackBlock : HeroParryResult?
    func defensiverParryAttack(hero:MXSHero, parry:ParryType, pokers:[MXSPoker]?, pokerWay:LosePokerWay?) {
        if parry == .failed {
            MXSJudge.cmd.responderSufferConsequence { spoils, pokers in
                if spoils == .destroy {
                    passedView.collectPoker(pokers!)
                }
                else if spoils == .wrest {
                    
                }
                else if spoils == .injured {
                    if hero.HPCurrent <= 0 {
                        return
                    }
                }
            }
        }
        else if parry == .success {
            passedView.collectPoker(pokers!)
        }
        else if parry == .unneed { }
        else if parry == .gain { }
        else if parry == .operate {
            leadingView.state = .defenseUnPick
            MXSLog("there need Return")
            return
        }
        
        MXSLog("step done")
        MXSJudge.cmd.theHeroHasReplyed()
        checkResponderAndWaitReply()
    }
    
    override func offensiveEndActiveSubject() {
        player.endCurrentCycle { hero in
            self.turnToAIAttack()
        }
    }
    
    override func defensiveCertainSubject() {
//        self.playerParryAttackBlock?(.unneed, nil, nil)
        
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
        
        MXSJudge.cmd.theHeroHasReplyed()
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
        
        MXSJudge.cmd.responderSufferConsequence { spoils, pokers in
            if spoils == .destroy {
                passedView.collectPoker(pokers!)
            }
            else if spoils == .wrest {
                //let pok_view = MXSPokerView()
            }
            else if spoils == .injured {
                if player.HPCurrent <= 0 {
                    return
                }
                else {
                    
                }
            }
            
            MXSJudge.cmd.theHeroHasReplyed()
            self.checkResponderAndWaitReply()
        }
    }
    
    
    // MARK: - hero
    
    
    // MARK: - application
    override var prefersStatusBarHidden: Bool {
        return true
    }

}
