//
//  MXSJudge.swift
//  Possible
//
//  Created by Sunfei on 2020/9/30.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit

class MXSJudge {
    /**
     * |      --------cycle------>       |
     * |
     * | leader <- _active -> _responder |
     * |
     * |      <-------cycle-------       |
     */
    
    static let cmd : MXSJudge = {
        let single = MXSJudge.init()
        return single
    }()
    
    var subject:Array<MXSHero> = Array<MXSHero>()
    /**hero action pokeres aim?  /hp  /cycle  */
    var diary:Array<MXSOneAction> = Array<MXSOneAction>()
    weak var desktop :MXSGroundController?
    
    //MARK: - intermediary
    func appendOrRemoveResponder(_ hero:MXSHero) {
        if hero.cycleState == .blank {
            hero.cycleState = .responder
            hero.signStatus = .selected
        }
        else if hero.cycleState == .responder {
            hero.cycleState = .blank
            hero.signStatus = .blank
        }
    }
    
    func clearResponder() {
        for hero in responder {
            hero.cycleState = .blank
            hero.signStatus = .blank
        }
//        for hero in subject {
//            if hero.cycleState != .leader {
//                hero.cycleState = .blank
//                hero.signStatus = .blank
//            }
//        }
    }
    
    func selectAllElseSelf() {
        let others = self.subject.filter { hero in
            hero.cycleState == .blank
        }
        for hero in others {
            hero.cycleState = .responder
            hero.signStatus = .selected
        }
    }
    
    //MARK: - leader cycle
    var flowNote:Int = -1
    var leader:MXSHero? {
        didSet {
            leader!.holdAction = MXSOneAction(axle: leader!, type: .active)
            leader!.signStatus = .active
            leader!.cycleState = .leader
        }
    }
    func dealcardForGameStart() {
        for hero in subject {
            hero.getPokers(MXSPokerCmd.shared.push(4))
        }
    }
    
    func dealcardForNextLeader(reBlock:(_ hero :MXSHero, _ pokers :[MXSPoker]?) -> Void) {
        
        if leader != nil {
            for hero in subject { hero.cycleState = .blank }
            leader!.endActiveByClearStatus()
            
            leader!.holdAction!.categy = .endLead //note end lead
            diary.append(leader!.holdAction!)
        }
        
        flowNote += 1
        MXSLog("--------------------------")
        MXSLog(flowNote, "Did set flow note:")
        let hero = subject[flowNote%subject.count]
        self.leader = hero
        
        let pokers = MXSPokerCmd.shared.push(leader!.collectNumb)
        leader!.getPokers(pokers)
        reBlock(leader!, pokers)
        
    }
    
    func playerCanAttack() -> Bool {
        guard leader != nil else {
            return false
        }
        if leader!.picked.count == 0  { return false }
        
        guard leader!.picked.first != nil else { //test this code
            return false
        }
        
        let action:PokerAction = leader!.holdAction!.action
        if action == .unknown { return false }
        
        if responder.count == 0 { //no aim
            if action == .remedy && leader!.HPCurrent < leader!.HPSum { return true }
            if (action == .warFire || action == .arrowes) { return true }
        }
        else {
            if action == .attack {
                return leader!.attackCount < leader!.attackLimit
            }
            if action == .duel {
                return true
            }
            if (action == .steal || action == .destroy) && responder.first!.holdPokers.count > 0 {
                return true
            }
            if action == .remedy && responder.first!.HPCurrent < responder.first!.HPSum  {
                return true
            }
        }
        
        return false
    }
    
    
    func markDiscardedOnAction() {
        leader?.holdAction?.pokers.append(contentsOf: leader!.picked)
        MXSLog(leader?.holdAction?.pokers as Any, "action note pokers")
    }
    func leaderReactive() {
        clearResponder()
        leader?.signStatus = .active
        
        leader!.holdAction = MXSOneAction(axle: leader!, type: .active)
    }
    
    
    //MARK: - responder
//    var responder:Array<MXSHero> = Array<MXSHero>()
    var responder:Array<MXSHero> {
        return self.subject.filter { hero in
            hero.cycleState == .responder
        }
    }
    
    func aimHavingPoker() -> Bool {
        let hero:MXSHero = responder.first!
        return hero.holdPokers.count > 0
    }
    
    func AIReplyAsResponder(reBlock:(_ type :ReplyResultType, _ pokers :Array<MXSPoker>?) -> Void) {
        
        let action_reply: PokerAction = self.leader!.holdAction!.reply.act
        if let responder_one = responder.first { //expect
            responder_one.holdAction = MXSOneAction(axle: responder_one, type: .reply)
            diary.append(responder_one.holdAction!)
            
            if action_reply == .recover {
                let _ = responder_one.plusHP()
                reBlock(.nothing, nil)
            }
            else if action_reply == .gain {
                responder_one.getPokers(leader!.holdAction!.pokers)
                reBlock(.gain, leader?.holdAction?.pokers)
            }
            else {// need
                
                if let idx = responder_one.holdPokers.firstIndex(where: { poker in
                    poker.actionGuise == action_reply
                }) {
                    let contain = responder_one.holdPokers[idx]
                    responder_one.losePokers([contain])
                    if leader?.holdAction?.action == .warFire || leader?.holdAction?.action == .arrowes {
                        MXSLog("MXSJudge set responder ---------------------->  reply group")
                    }
                    reBlock(.success, [contain])
                }
                else {
                    if leader?.holdAction?.action == .warFire || leader?.holdAction?.action == .arrowes {
                        MXSLog("MXSJudge set responder ----------------------> can't reply group")
                    }
                    reBlock(.failed, nil) }
            }
        }
        else { // no aim
            
            let categy = self.leader!.holdAction!.categy
            if categy == .group {
                selectAllElseSelf()
                //TODO: group, taketurns = one by one
//                takeTurnsReply()
                MXSLog("MXSJudge set responder ------ >>")
                AIReplyAsResponder(reBlock: reBlock)
            }
        }
    }
    
    //MARK: - group = taketurns
//    func findOneByOneResponder() -> MXSHero? {
//        return responder.first
//    }
//    func takeTurnsReply() {
//        if let someone = findOneByOneResponder() {
//
//        }
//    }
    
    func responderSufferConsequence(reBlock:(_ spoils :SpoilsType, _ pokers :Array<MXSPoker>?) -> Void) {
        let hero:MXSHero = responder.first!
        let action = MXSJudge.cmd.leader?.holdAction?.action
        switch action {
        case .unknown, .defense, .detect, .give, .recover, .gain:
            reBlock(.nothing, nil)
        case .attack, .warFire, .arrowes, .duel:
            hero.minsHP()
            reBlock(.nothing, nil)
        case .steal:
            let random = hero.rollRandomPoker()
            hero.losePokers([random])
            MXSJudge.cmd.leader?.getPokers([random])
            reBlock(.wrest, [random])
        case .destroy:
            let random = hero.rollRandomPoker()
            hero.losePokers([random])
            reBlock(.destroy, [random])
        case .remedy:
            let _ = hero.plusHP()
            reBlock(.nothing, nil)
        case .none:
            break
        }
    }
    
    func responderGainPoker(_ pokers:[MXSPoker]) -> Void {
        let responder_one = responder.first!
        responder_one.getPokers(pokers)
    }
    
    //MARK: - judge
    func canDefence() -> Bool {
        let action_reply: PokerAction = self.leader!.holdAction!.reply.act
        let responder_one = responder.first!
        MXSLog(action_reply, "attack's reply action")
        MXSLog(responder_one.holdAction?.action as Any, "defence action")
        return responder_one.holdAction?.action == action_reply
    }
    
    //MARK: - for AI
    
    func returnMinHero() -> MXSHero? {
//        let others = self.subject.filter { hero in
//            hero.cycleState == .blank
//        }
//        return others.first!
        MXSLog("Judge.subject: " + "\(self.subject)")
        let hero = self.subject.first { hero in
            hero.cycleState == .blank
        }
        MXSLog(hero?.name as Any, "AI aim at hero")
        return hero
    }
}
