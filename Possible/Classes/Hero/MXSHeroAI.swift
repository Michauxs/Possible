//
//  MXSHeroAI.swift
//  Possible
//
//  Created by Sunfei on 2022/1/26.
//  Copyright © 2022 boyuan. All rights reserved.
//

import Foundation

extension MXSHero {
    
    /**AI 操作逻辑设定*/
    
    func replyAttack() -> MXSPoker? {
        if isPlayer { return nil }
        
        let action_attck = MXSJudge.cmd.leader?.holdAction?.action
        switch action_attck {
        case .attack:
            return minsHPOrDefenseWithAction(.dodge)
        case .warFire:
            return minsHPOrDefenseWithAction(.attack)
        case .arrowes:
            return minsHPOrDefenseWithAction(.dodge)
        case .destroy:
            return distributeWithState(.pass)
        case .steal:
            return distributeWithState(.transferring)
        default: break
        }
        
        return nil
    }
    func distributeWithState(_ state:PokerState) -> MXSPoker {
        if let poker = hasPokerWithAction(.detect) {
            popCard(poker)
            return poker
        } else {
            let index = Int(arc4random_uniform(UInt32(self.ownPokers.count)))
            let pok_random = self.ownPokers.remove(at: index)
            pok_random.state = state
            return pok_random
        }
    }
    func minsHPOrDefenseWithAction(_ action:PokerAction) -> MXSPoker? {
        if let poker = hasPokerWithAction(action) {
            popCard(poker)
            return poker
        }
        else {
            self.HPDecrease()
            return nil
        }
    }
    func hasPokerWithAction(_ action:PokerAction) -> MXSPoker? {
        if let index = self.ownPokers.firstIndex(where: { (item) -> Bool in item.actionGuise == action }) {
            return self.ownPokers[index]
        }
        else { return nil }
    }
    
    public func popCard(_ poker:MXSPoker) {
        self.ownPokers.removeAll(where: {$0 === poker})
        poker.state = .pass
        if poker.actionGuise == PokerAction.attack {
            attackCount += 1
        }
    }
    
    
    //MARK: - AI leader
    typealias AttackResultCallback = (_ target: MXSHero?, _ action: PokerAction, _ pokers: [MXSPoker]?, _ pokerWay: PokerViewWay?, _ callback: @escaping CallbackBlock) -> Void
    public func canAttack(attackResult: AttackResultCallback, next:@escaping CallbackBlock) -> Bool {
        if self.ownPokers.count == 0 {
            return false
        }
        /**在调用方法中callback**/
        func callback() {
            next()
        }
        
        if self.HPCurrent < self.HPSum {
            if let index = self.ownPokers.firstIndex(where: { (item) -> Bool in item.actionGuise == .remedy }) {
                let poker = self.ownPokers[index]
                MXSJudge.cmd.appendResponder(self)
                self.pickPoker(poker)
                attackResult(self, .remedy, [poker], .passed, callback)
                return true
            }
        }
        
        var target = MXSJudge.cmd.returnMinHero()
        if target == nil {
            return false
        }
        
        var action_note: PokerAction?
        var pokers = [MXSPoker]()
        var pokWay: PokerViewWay?
        
        //[.steal, .destroy, .warFire, .arrowes, .duel, .attack]
        for action in MXSPokerCmd.shared.priority {
            if let index = self.ownPokers.firstIndex(where: { (item) -> Bool in item.actionGuise == action }) {
                let poker = self.ownPokers[index]
                action_note = action
                switch action {
                case .steal, .destroy:
                    if target!.ownPokers.count == 0 { continue }
                    pokers.append(poker)
                    pokWay = .passed
                    break
                    
                case .attack:
                    if attackCount >= attackLimit { continue }
                    pokers.append(poker)
                    pokWay = .passed
                    break
                    
                case .warFire, .arrowes:
                    target = nil;
                    pokers.append(poker)
                    pokWay = .passed
                    break
                    
                case .duel:
                    pokers.append(poker)
                    pokWay = .passed
                    break
                    
                default: continue
                }//switch
            }//index
        }//for
        
        if pokers.count > 0 {
            if target == nil {
                MXSJudge.cmd.selectAllPlayer()
            }
            else {
                MXSJudge.cmd.appendResponder(target!)
            }
                
            self.pickPokers(pokers)
            self.losePokers(self.picked)
            MXSJudge.cmd.diary.append(self.holdAction!)
            
            attackResult(target, action_note!, pokers, pokWay!, callback)
            return true
        }
        
        return false
    }
    
}
