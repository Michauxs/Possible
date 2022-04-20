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
        
        let action_attck = MXSJudge.cmd.leader?.currentAction?.action
        switch action_attck {
        case .attack:
            return minsHPOrDefenseWithAction(.defense)
        case .warFire:
            return minsHPOrDefenseWithAction(.attack)
        case .arrowes:
            return minsHPOrDefenseWithAction(.defense)
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
            let index = Int(arc4random_uniform(UInt32(self.pokers.count)))
            let pok_random = self.pokers.remove(at: index)
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
        if let index = self.pokers.firstIndex(where: { (item) -> Bool in item.actionGuise == action }) {
            return self.pokers[index]
        }
        else { return nil }
    }
    
    public func popCard(_ poker:MXSPoker) {
        self.pokers.removeAll(where: {$0 === poker})
        poker.state = .pass
        if poker.actionGuise == PokerAction.attack {
            attackCount += 1
        }
    }
    
    //MARK: - AI leader
    func choiceResponder() {
        self.takeOrDisAimAtHero(MXSJudge.cmd.returnMinHero())
    }
    
    public func hasPokerDoAttack(reBlock:(_ has :Bool, _ pokers :Array<MXSPoker>?, _ skill:MXSSkill?) -> Void) {
        if MXSJudge.cmd.responder.count == 0 || self.pokers.count == 0 {
            reBlock(false, nil, nil)
        }
        
        var hasPoker:Bool = false
        for action in MXSPokerCmd.shared.priority {
            if let index = self.pokers.firstIndex(where: { (item) -> Bool in item.actionGuise == action }) {
                let poker = self.pokers[index]
                /**attack yet , check next action*/
                if (action == PokerAction.attack ) && self.attackCount != 0 { continue }
                /**aim no anyone poker , check next action*/
                if (action == PokerAction.steal || action == PokerAction.destroy) && MXSJudge.cmd.aimHavingPoker() { continue }
                
                hasPoker = true
                reBlock(hasPoker, [poker], nil)
                return
            }
        }
        
        reBlock(false, nil, nil)
    }
    
}