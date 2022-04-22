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
    var flowNote:Int = 0
    var leader:MXSHero? {
        didSet {
            leader!.holdAction = MXSOneAction(axle: leader!, type: .active)
            leader!.signStatus = .active
            leader!.cycleState = .leader
        }
    }
    
    func next() {
        for hero in subject { hero.cycleState = .blank }
        self.leader?.endActiveAndClearHistory()
        
        MXSLog("did set flow note")
        flowNote += 1
        let hero = subject[flowNote%subject.count]
        self.leader = hero
    }
    
    func leaderCanAttack() -> Bool {
        guard leader != nil else {
            return false
        }
        if leader!.pickes.count == 0  { return false }
        
        guard leader!.pickes.first != nil else { //test this code
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
            if (action == .steal || action == .destroy) && responder.first!.pokers.count > 0 {
                return true
            }
            if action == .remedy && responder.first!.HPCurrent < responder.first!.HPSum  {
                return true
            }
        }
        
        return false
    }
    
    
    func markDiscardedOnAction() {
        leader?.holdAction?.pokers.append(contentsOf: leader!.pickes)
    }
    func leaderReactive() {
        clearResponder()
        leader?.signStatus = .active
        
        leader?.lastStep = leader?.holdAction
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
        return hero.pokers.count > 0
    }
    
    func responderReplyAction(reBlock:(_ type :ReplyResultType, _ pokers :Array<MXSPoker>?) -> Void) {
        let categy = self.leader!.holdAction!.categy
        if categy == .group {
            selectAllElseSelf()
            //TODO: group, taketurns = one by one
        }
        let responder_un = responder.first
        let action_reply: PokerAction = self.leader!.holdAction!.reply.act
        if responder_un == nil {
            if action_reply == .recover {
                let _ = self.leader?.plusHP()
                reBlock(.nothing, nil)
            }
            return
        }
        
        let responder_one = responder.first!
        if action_reply == .recover {
            let _ = responder_one.plusHP()
            reBlock(.nothing, nil)
        }
        else if action_reply == .gain {
            responder_one.getPoker(leader!.holdAction!.pokers)
            reBlock(.gain, leader?.holdAction?.pokers)
        }
        else {// need
//            if responder_one.pokers.count < 1 {
//                reBlock(.failed, nil)
//                return
//            }
            
            let contain = responder_one.pokers.filter { poker in
                poker.actionGuise == action_reply
            }
            if contain.count > 0 {
                responder_one.losePoker(contain)
                reBlock(.success, [contain.first!])
            }
            else { reBlock(.failed, nil) }
        }
    }
    
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
            hero.losePoker([random])
            MXSJudge.cmd.leader?.getPoker([random])
            reBlock(.wrest, [random])
        case .destroy:
            let random = hero.rollRandomPoker()
            hero.losePoker([random])
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
        responder_one.getPoker(pokers)
    }
    
    
    //MARK: - for AI
    
    func returnMinHero() -> MXSHero {
//        let others = self.subject.filter { hero in
//            hero.cycleState == .blank
//        }
//        return others.first!
        MXSLog("Judge.subject: " + "\(self.subject)")
        let hero = self.subject.first { hero in
            hero.cycleState == .blank
        }
        return hero!
    }
}
