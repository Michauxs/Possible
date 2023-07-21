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
            self.minsHP()
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
    public func hasPokerDoAttack(reBlock:(_ has :Bool, _ pokers :[MXSPoker]?, _ skill:MXSSkill?) -> Void) {
        if self.ownPokers.count == 0 {
            reBlock(false, nil, nil)
            return
        }
        
        
        var hasPoker:Bool = false
        for action in MXSPokerCmd.shared.priority {
            if let index = self.ownPokers.firstIndex(where: { (item) -> Bool in item.actionGuise == action }) {
                let poker = self.ownPokers[index]
                switch action {
                case .unknown, .dodge, .detect, .recover, .gain:
                    hasPoker = false
                case .steal, .destroy:
                    if let target = MXSJudge.cmd.returnMinHero() {
                        MXSJudge.cmd.appendResponder(target)
                        hasPoker = MXSJudge.cmd.aimHavingPoker()
                    }
                case .attack:
                    if let target = MXSJudge.cmd.returnMinHero() {
                        MXSJudge.cmd.appendResponder(target)
                        hasPoker = attackCount < attackLimit
                    }
                case .warFire, .arrowes:
                    hasPoker = true
                case .duel:
                    if let target = MXSJudge.cmd.returnMinHero() {
                        MXSJudge.cmd.appendResponder(target)
                        hasPoker = true
                    }
                case .remedy:
                    if let target = MXSJudge.cmd.returnMinHero() {
                        MXSJudge.cmd.appendResponder(target)
                        hasPoker = target.canRecover()
                    }
                    else { hasPoker = self.canRecover() }
                case .give:
                    hasPoker = false
                }
                
                if hasPoker {
                    reBlock(hasPoker, [poker], nil)
                    return
                }
            }//
                
        }
        
        reBlock(hasPoker, nil, nil)
    }
    
    public func asReplyerParryAttack(reBlock:(_ type:ReplyResultType, _ pokers:[MXSPoker]?) -> Void) {
        let leader = MXSJudge.cmd.leader!
        let action_reply: PokerAction = leader.holdAction!.reply.act
        
        MXSJudge.cmd.diary.append(self.holdAction!)
        
        if action_reply == .recover {
            let _ = self.plusHP()
            reBlock(.nothing, nil)
        }
        else if action_reply == .gain {
            self.getPokers(leader.holdAction!.pokers)
            reBlock(.gain, leader.holdAction?.pokers)
        }
        else {// need parry
            if self.isAxle {
                reBlock(.operate, nil)
            }
            else {
                //AI
                if let index = self.ownPokers.firstIndex(where: { poker in poker.actionGuise == action_reply }) {
                    let contain = self.ownPokers[index]
                    self.losePokers([contain])
                    reBlock(.success, [contain])
                    
                    if leader.holdAction?.aimType == .aoe { MXSLog("responder ---------->  reply group") }
                }
                else {
                    reBlock(.failed, nil)
                    
                    if leader.holdAction?.aimType == .aoe { MXSLog("responder ----------> can't reply group") }
                }
            }
        }
        
    }
    
}
