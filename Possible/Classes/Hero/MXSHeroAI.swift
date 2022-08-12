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
        if isAxle { return nil }
        
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
            let index = Int(arc4random_uniform(UInt32(self.holdPokers.count)))
            let pok_random = self.holdPokers.remove(at: index)
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
            self.minsHP()
            return nil
        }
    }
    func hasPokerWithAction(_ action:PokerAction) -> MXSPoker? {
        if let index = self.holdPokers.firstIndex(where: { (item) -> Bool in item.actionGuise == action }) {
            return self.holdPokers[index]
        }
        else { return nil }
    }
    
    public func popCard(_ poker:MXSPoker) {
        self.holdPokers.removeAll(where: {$0 === poker})
        poker.state = .pass
        if poker.actionGuise == PokerAction.attack {
            attackCount += 1
        }
    }
    
    //MARK: - AI leader
    public func hasPokerDoAttack(reBlock:(_ has :Bool, _ pokers :[MXSPoker]?, _ skill:MXSSkill?) -> Void) {
        if self.holdPokers.count == 0 {
            reBlock(false, nil, nil)
            return
        }
        
        var hasPoker:Bool = false
        for action in MXSPokerCmd.shared.priority {
            if let index = self.holdPokers.firstIndex(where: { (item) -> Bool in item.actionGuise == action }) {
                let poker = self.holdPokers[index]
                switch action {
                case .unknown, .dodge, .detect, .recover, .gain:
                    hasPoker = false
                case .steal, .destroy:
                    if let target = MXSJudge.cmd.returnMinHero() {
                        self.takeOrDisAimAtHero(target)
                        hasPoker = MXSJudge.cmd.aimHavingPoker()
                    }
                case .attack:
                    if let target = MXSJudge.cmd.returnMinHero() {
                        self.takeOrDisAimAtHero(target)
                        hasPoker = attackCount < attackLimit
                    }
                case .warFire:
                    hasPoker = true
                case .arrowes:
                    hasPoker = true
                case .duel:
                    if let target = MXSJudge.cmd.returnMinHero() {
                        self.takeOrDisAimAtHero(target)
                        hasPoker = true
                    }
                case .remedy:
                    if let target = MXSJudge.cmd.returnMinHero() {
                        self.takeOrDisAimAtHero(target)
                        hasPoker = target.canRecover()
                    }
                    else { hasPoker = self.canRecover() }
                case .give:
                    hasPoker = false
                default:
                    break
                }
                
                if hasPoker {
                    reBlock(hasPoker, [poker], nil)
                    return
                }
            }//
                
        }
        
        reBlock(hasPoker, nil, nil)
    }
    
}
