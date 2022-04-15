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
//            layoutSkillViews(skilles: player.skillSet)
            
            MXSNetServ.shared.send([kMessageType:MessageType.pickHero.rawValue, kMessageValue:hero.photo])
        }
    }
    func allHeroReady() {
        if MXSPokerCmd.shared.shuffle() {
            player.pokers.append(contentsOf: MXSPokerCmd.shared.push(6))
            layoutPokersInBox(update: 0)
            
            opponter.pokers.append(contentsOf: MXSPokerCmd.shared.push(6))
        }
        
        leaderExchange(player)
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
//    public override func certainForAttack() {
//        let poker = player.pickes.first!
//        player.pokers.removeAll(where: {$0 === poker})
//        poker.state = .pass
//
//        leadingView.isHidden = true
//        player.disPokerCurrentPickes()
//        self.updateViewsResponAttackWithPickedPokeres(pokeres: player.pickes)
//
//        actionCycle()
//    }
//    public override func updateViewsResponAttackWithPickedPokeres(pokeres:Array<MXSPoker>) {
//        let poker = pokeres.first!
//        if poker.actionGuise == PokerAction.attack {
//            player.attackCount += 1
//        }
//        else if poker.actionGuise == PokerAction.duel {
//            MXSJudge.cmd.passive.first?.minsHP()
//            MXSJudge.cmd.clearPassive()
//
//            leadingView.isHidden = false
//            leadingView.state = .attackUnPick
//
//            player.stopAllSkill(.enable)
//            layoutPokersInBox(update: 1)
//            cycleActive()
//            return
//        }
//        else if poker.actionGuise == PokerAction.recover {
//            if let aimed = MXSJudge.cmd.passive.first { //has aim
//                aimed.plusHP()
//            }
//            else {
//                player.plusHP()
//            }
//        }
//        player.signStatus = .blank
//
//        player.stopAllSkill(.enable)
//        layoutPokersInBox(update: 1)
//        cycleActive()
//    }
//
//    public override func cancelPickes() {
//        for poker in player.pickes { poker.concreteView?.isUp = false }
//        player.pickes.removeAll()
//        MXSJudge.cmd.clearPassive()
//    }
//
//    public override func endActive() {
//        leadingView.isHidden = true
//        leadingView.state = .defenseUnPick
//
//        MXSJudge.cmd.next()
//        passedView.fadeout()
//        leaderExchange(opponter)
//    }
//
//    public override func certainForDefense() {
//        MXSJudge.cmd.leaderReactive()
//        leadingView.isHidden = true
//        layoutPokersInBox(update: 1)
//
//        cycleActive()
//    }
//    public override func cancelForDefense() {
//        if player.pickes.count != 0 {
//            for poker in player.pickes { poker.concreteView?.isUp = false }
//            player.pickes.removeAll()
//        }
//
//        let action = MXSJudge.cmd.leaderActiveAction
//        if action == PokerAction.attack || action == PokerAction.warFire || action == PokerAction.arrowes {
//            player.minsHP()
//        }
//        if action == PokerAction.steal {
//            let index = Int(arc4random_uniform(UInt32(player.pokers.count)))
//            let poker_random = player.pokers.remove(at: index)
//            opponter.pokers.append(poker_random)
//
//            passedView.willCollect = false
//            player.pickes.append(poker_random)
//            layoutPokersInBox(update: 1)
//        }
//        if action == PokerAction.destroy {
//            let index = Int(arc4random_uniform(UInt32(player.pokers.count)))
//            let poker_random = player.pokers.remove(at: index)
//
//            player.pickes.append(poker_random)
//            layoutPokersInBox(update: 1)
//        }
//
//        MXSJudge.cmd.leaderReactive()
//        leadingView.isHidden = true
//
//        actionCycle()
//    }
    
    // MARK: - cycle: 1.leader exchange  2.active action  3.possive action
    func leaderExchange(_ leader:MXSHero) {
        /**通用数据部分**/
        MXSJudge.cmd.leader = leader
        let pokers = MXSPokerCmd.shared.push(2)
        leader.pokers.append(contentsOf: pokers)
        
        if leader.isAxle {
            leadingView.state = .attackUnPick
            newAndGraspMoreViews(pokers)
            
            player.adjustGrasp = true
            layoutPokersInBox(update: 1)
        }
        
        activeActionCycle()
    }
            
    func activeActionCycle() {
        guard let hero = MXSJudge.cmd.leader else {
            return
        }
        /**player视图部分**/
        if hero.isAxle {
            leadingView.state = .attackUnPick
//            newAndGraspMoreViews(pokers)
            
            player.adjustGrasp = true
            layoutPokersInBox(update: 1)
        }
        else {
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
//                self.actionCycle()
            }
        }
        
    }
    func possiveActionCycle() {
        guard let hero = MXSJudge.cmd.passive.first else {
            return
        }
        
        if hero.isAxle {
            leadingView.state = .defenseUnPick
        }
        else {
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
//                self.actionCycle()
            }
        }
    }
    
    override func playerCollectPoker(_ poker: MXSPoker) {
        player.pokers.append(poker)
        poker.state = .handOn
        newAndGraspMoreViews([poker])
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
            player.freePoker(poker)
        }
        
        checkCanCertainAction()
    }
    
    // MARK: - hero
    public override func someoneHeroTaped(_ heroView: MXSHeroView) {
        print("controller action hero")
        /**被动响应 无需选择*/
        if leadingView.state == LeadingState.defenseUnPick { return }
        
        MXSJudge.cmd.appendOrRemovePassive(heroView.belong!)
        checkCanCertainAction()
    }
    
    // MARK: - application
    override var prefersStatusBarHidden: Bool {
        return true
    }

}
