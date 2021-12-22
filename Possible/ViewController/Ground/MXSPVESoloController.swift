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
        pickHeroView.heroData = MXSHeroCmd.shared.allHeroModel
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

    //MARK:- Skill
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
    
    //MARK:- leadingView
    public override func certainForAttack() {
        let poker = player.pickes.first!
        player.pokers.removeAll(where: {$0 === poker})
        poker.state = .pass
        
        leadingView.isHidden = true
        player.disPokerCurrentPickes()
        self.updateViewsResponAttackWithPickedPokeres(pokeres: player.pickes)
    }
    public override func updateViewsResponAttackWithPickedPokeres(pokeres:Array<MXSPoker>) {
        let poker = pokeres.first!
        if poker.actionGuise == PokerAction.attack {
            player.attackCount += 1
        }
        else if poker.actionGuise == PokerAction.duel {
            MXSJudge.cmd.passive.first?.minsHP()
            MXSJudge.cmd.clearPassive()

            leadingView.isHidden = false
            leadingView.state = .attackUnPick
            
            player.stopAllSkill(.enable)
            layoutPokersInBox(update: 1)
            cycleActive()
            return
        }
        else if poker.actionGuise == PokerAction.recover {
            if let aimed = MXSJudge.cmd.passive.first { //has aim
                aimed.plusHP()
            }
            else {
                player.plusHP()
            }
        }
        player.signStatus = .blank
        
        player.stopAllSkill(.enable)
        layoutPokersInBox(update: 1)
        cycleActive()
    }
    
    public override func cancelPickes() {
        for poker in player.pickes { poker.concreteView?.isUp = false }
        player.pickes.removeAll()
        MXSJudge.cmd.clearPassive()
    }
        
    public override func endActive() {
        leadingView.isHidden = true
        leadingView.state = .defenseUnPick
        
        MXSJudge.cmd.next()
        passedView.fadeout()
        cycleActive()
    }
    
    public override func certainForDefense() {
        MXSJudge.cmd.leaderReactive()
        leadingView.isHidden = true
        layoutPokersInBox(update: 1)
        
        cycleActive()
    }
    public override func cancelForDefense() {
        if player.pickes.count != 0 {
            for poker in player.pickes { poker.concreteView?.isUp = false }
            player.pickes.removeAll()
        }
        
        let action = MXSJudge.cmd.leaderActiveAction
        if action == PokerAction.attack || action == PokerAction.warFire || action == PokerAction.arrowes {
            player.minsHP()
        }
        if action == PokerAction.steal {
            let index = Int(arc4random_uniform(UInt32(player.pokers.count)))
            let poker_random = player.pokers.remove(at: index)
            opponter.pokers.append(poker_random)
            
            passedView.willCollect = false
            player.pickes.append(poker_random)
            layoutPokersInBox(update: 1)
        }
        if action == PokerAction.destroy {
            let index = Int(arc4random_uniform(UInt32(player.pokers.count)))
            let poker_random = player.pokers.remove(at: index)
            
            player.pickes.append(poker_random)
            layoutPokersInBox(update: 1)
        }
        
        MXSJudge.cmd.leaderReactive()
        leadingView.isHidden = true
        
        cycleActive()
    }
    
    //MARK:- cycle active exchange
    override func cycleActive() {
        if let hero = MXSJudge.cmd.active {
            if hero.isAxle {
                leadingView.isHidden = false
                if hero === MXSJudge.cmd.leader { //leader
                    leadingView.state = .attackUnPick
                    if !hero.isCollectedCard { //第一圈开始
                        hero.isCollectedCard = true
                        let arr = MXSPokerCmd.shared.push(2)
                        hero.pokers.append(contentsOf: arr)
                        newAndGraspMoreViews(arr)
                        player.adjustGrasp = true
                        layoutPokersInBox(update: 1)
                    }
                }
                else {//passive
                    leadingView.state = .defenseUnPick
                    
                }
            }
            else { //AI /oppot
                if hero === MXSJudge.cmd.leader { //leader
                    if !hero.isCollectedCard { //first
                        hero.pokers.append(contentsOf: MXSPokerCmd.shared.push(2))
                        hero.isCollectedCard = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        MXSJudge.cmd.appendOrRemovePassive(self.player)
                        if let poker = hero.hasPokerDoAttack() {
                            hero.pickes.append(poker)
                            if hero.discard() {
                            }
                            hero.pickes.removeAll()
                            self.passedView.collectPoker(pokers: [poker])
                        }
                        else {
                            
                            MXSJudge.cmd.next()
                            self.passedView.fadeout()
                        }
                        self.cycleActive()
                    }
                    
                }
                else {//passive
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        if let poker_return = hero.replyAttack() {
                            if poker_return.state == PokerState.transferring {// steal
                                self.playerCollectPoker(poker_return)
                                self.layoutPokersInBox(update: 1)
                            }
                            else {//destroy / defense
                                self.passedView.collectPoker(pokers: [poker_return])
                            }
                        }
                        
                        MXSJudge.cmd.leaderReactive()
                        self.cycleActive()
                    }
                }
            }
        
        }
    }
        
    override func playerCollectPoker(_ poker: MXSPoker) {
        player.pokers.append(poker)
        poker.state = .handOn
        newAndGraspMoreViews([poker])
    }
    
    override func newAndGraspMoreViews(_ pokers:Array<MXSPoker>){
        let view_last = graspPokerViewes.last
        for poker in pokers {
            let pokerView = MXSPokerView.init()
            pokerScrollView.addSubview(pokerView)
            pokerView.frame = CGRect.init(x: view_last?.frame.origin.x ?? 0.0, y: PPedMargin, width: MXSSize.Pw, height: MXSSize.Ph)
            pokerView.controller = self
            poker.concreteView = pokerView
            graspPokerViewes.append(pokerView)
        }
    }
    
    
    @objc public override func someonePokerTaped(_ pokerView: MXSPokerView) {
        if let index = player.pokers.firstIndex(where: {$0 === pokerView.belong}) {
            print("controller action pok at " + "\(index)")
        }
        
        pokerView.isUp = !pokerView.isUp
        let poker = pokerView.belong!
        if pokerView.isUp {
            player.pickPoker(poker)
        } else {
            player.disPickPoker(poker)
        }
        
        checkCanCertainAction()
    }
    
    //MARK:- hero
    public override func someoneHeroTaped(_ heroView: MXSHeroView) {
        print("controller action hero")
        /**被动响应 无需选择*/
        if leadingView.state == LeadingState.defenseUnPick { return }
        
        MXSJudge.cmd.appendOrRemovePassive(heroView.belong!)
        checkCanCertainAction()
    }
    
    //MARK:- action
    override func checkCanCertainAction() {
        if player.signStatus == .focus {
            if player.canDefense() {
                leadingView.state = .defenseReadyOn
            }
            else {
                leadingView.state = .defenseUnPick
            }
        }
        else {
            if player.canAttack() {
                leadingView.state = .attackReadyOn
            }
            else {
                if player.pickes.count > 0 { leadingView.state = .attackPicked }
                else { leadingView.state = .attackUnPick }
            }
        }
            
    }
    
    //MARK:application
    override var prefersStatusBarHidden: Bool {
        return true
    }

}
