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
            player.isPlayer = true
            
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
            
            MXSJudge.cmd.dealcardForGameStart { heroArray, pokersArray in
                for index in 0..<heroArray.count {
                    let hero = heroArray[index]
                    let pokers = pokersArray[index]
                    hero.holdHisPokersView(pokers) {
                        
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: DispatchWorkItem(block: { [self] in
                    MXSJudge.cmd.turnLeaderAndDealcard { leader, pokers in
                        leader.holdHisPokersView(pokers!) { [self] in
                            
                            if leader.isPlayer {
                                leadingView.state = .attackUnPick
                            }
                            else {
                                turnToAIAttack()
                            }
                        }
                    }
                }))
                
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
    
    // MARK: - offensive
    override func checkResponderWaitReplyOrReactive() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(750)) { [self] in
            
            guard let responder = MXSJudge.cmd.trySomeoneAsResponderToReply() else {
                MXSLog("find responder failed")
                if MXSJudge.cmd.leader!.isPlayer {
                    leadingView.state = .attackUnPick
                }
                else {
                    turnToAIAttack()
                }
                return
            }
            
            responder.parryAttack { parry, pokers, pokerWay, callback in
                if parry == .recover {
                    MXSLog(responder.name, "hp +")
                    let _ = responder.HPIncrease()
                    callback()
                    return
                }
                else if parry == .receive {
                    responder.getPokers(pokers!)
                }
                else if parry == .beDestroyed || parry == .answered {
                    responder.losePokers(pokers!)
                }
                else if parry == .beStolen {
                    responder.losePokers(pokers!)
                    MXSJudge.cmd.leader!.getPokers(pokers!)
                }
                else if parry == .injured {
                    responder.HPDecrease()
                    MXSLog(responder.name, "HP mins")
                    if responder.HPCurrent <= 0 {
                        MXSLog("some hero faied")
                        return
                    }
                }
                else if parry == .operate {
                    leadingView.state = .defenseUnPick
                    MXSLog("player operate")
                    return
                }
                MXSLog(responder.name + " parryResult'block not return")
                
                /***/
                if pokerWay == .passed {
                    passedView.depositPoker(pokers!, fromHero: responder) {
                        callback()
                    }
                }
                else if pokerWay == .dealcards {
                    responder.holdHisPokersView(pokers!) {
                        callback()
                    }
                }
                else if pokerWay == .comefrom {
                    self.pokerHandover(pokers: pokers!, from: MXSJudge.cmd.leader!, to: responder) {
                        MXSLog("poker handvoer:come finished")
                        responder.holdHisPokersView(pokers!) {
                            callback()
                        }
                    }
                }
                else if pokerWay == .awayfrom {
                    self.pokerHandover(pokers: pokers!, from: responder, to: MXSJudge.cmd.leader!) {
                        MXSLog("poker handvoer:away finished")
                        callback()
                    }
                }
                else {
                    callback()
                }
                
            } next: { [self] in
                MXSLog("step done")
                MXSJudge.cmd.currentResponderDone()
                checkResponderWaitReplyOrReactive()
            }
            
        }
    }
    
    
    override func offensiveEndActiveSubject() {
        MXSJudge.cmd.turnLeaderAndDealcard { leader, pokers in
            leader.holdHisPokersView(pokers!) {
                if leader.isPlayer { //no any possible
                    self.leadingView.state = .attackUnPick
                }
                else {
                    self.turnToAIAttack()
                }
            }
        }
    }
    
    func turnToAIAttack() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(750)) { [self] in
            let leader = MXSJudge.cmd.leader!
            if leader.canAttack(attackResult: { target, action, pokers, pokerWay, callback in
                if pokerWay == .passed {
                    passedView.depositPoker(pokers!, fromHero: leader) {
                        callback()
                    }
                }
                else if pokerWay == .awayfrom {
                    self.pokerHandover(pokers: pokers!, from: leader, to: target!) {
                        callback()
                    }
                }
            }, next: { [self] in
                checkResponderWaitReplyOrReactive()
                
            }) == false {
                MXSLog(leader.name, "AI can't attack -")
                passedView.fadeout()
                MXSJudge.cmd.turnLeaderAndDealcard { leader, pokers in
                    leader.holdHisPokersView(pokers!) {
                        if leader.isPlayer {
                            self.leadingView.state = .attackUnPick
                        }
                        else {
                            self.turnToAIAttack()
                        }
                    }
                }
            }//if
        }//after
    }
    
    //MARK: -- defensive
    override func defensiveCertainSubject() {
            
        let responder = MXSJudge.cmd.responder.first
        responder?.discardPoker(reBlock: { target, pokerWay, pokers in
            if pokerWay == .passed {
                MXSLog(pokers, "player discard poker")
                graspPokerView.losePokerView(pokers) {
                    self.passedView.depositPoker(pokers, fromHero: responder!) {
                        MXSJudge.cmd.currentResponderDone()
                        self.checkResponderWaitReplyOrReactive()
                    }
                }
            }
            else if pokerWay == .awayfrom {// = active give + responder gain
                self.pokerHandover(pokers: pokers, from: responder!, to: target!) {
                    MXSJudge.cmd.currentResponderDone()
                    self.checkResponderWaitReplyOrReactive()
                }
            }
        })
    }
    
    override func defensiveCancelSubject() {
        let responder = MXSJudge.cmd.responder.first!
        responder.sufferConsequence(reBlock: { parry, pokers, pokerWay, callback in
            if parry == .beDestroyed {
                responder.losePokers(pokers!)
            }
            else if parry == .beStolen {
                responder.losePokers(pokers!)
                MXSJudge.cmd.leader!.getPokers(pokers!)
            }
            else if parry == .injured {
                responder.HPDecrease()
                MXSLog(responder.name, "HP mins")
                if responder.HPCurrent <= 0 {
                    MXSLog("player faied")
                    return
                }
            }
            MXSLog(responder.name + " palyer'block not return")
            
            /***/
            if pokerWay == .passed {
                passedView.depositPoker(pokers!, fromHero: responder) {
                    callback()
                }
            }
            else if pokerWay == .dealcards {
                responder.holdHisPokersView(pokers!) {
                    callback()
                }
            }
            else if pokerWay == .handle {
                MXSLog("poker handvoer finished: handle...")
                responder.holdHisPokersView(pokers!) {
                    callback()
                }
            }
            else if pokerWay == .awayfrom {
                self.pokerHandover(pokers: pokers!, from: responder, to: MXSJudge.cmd.leader!) {
                    MXSLog("poker handvoer: away finished")
                    callback()
                }
            }
            else {
                callback()
            }
            
        }, next: { [self] in
            MXSLog("=== step done ===")
            MXSJudge.cmd.currentResponderDone()
            checkResponderWaitReplyOrReactive()
        })
    }
    
    
    // MARK: - hero
    
    
    
    // MARK: - application
    override var prefersStatusBarHidden: Bool {
        return true
    }

}
