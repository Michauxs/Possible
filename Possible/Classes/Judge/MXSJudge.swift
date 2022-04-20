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
    
    //MARK: - leader cycle
    var flowNote:Int = 0
    var leader:MXSHero? {
        didSet {
            leader!.currentAction = MXSOneAction(axle: leader!, type: .active)
            leader!.signStatus = .active
            leader!.cycleState = .leader
        }
    }
    func next() {
        for hero in subject { hero.cycleState = .blank }
        self.leader?.endActiveAndClearHistory()
        
        print("did set flow note")
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
        
        let action:PokerAction = leader!.currentAction!.action
        if action == .unknown { return false }
        
        if responder.count == 0 { //no aim
            if action == .recover && leader!.HPCurrent < leader!.HPSum { return true }
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
            if action == .recover && responder.first!.HPCurrent < responder.first!.HPSum  {
                return true
            }
        }
        
        return false
    }
    
    func leaderReactive() {
        clearResponder()
        leader?.signStatus = .active
        
        leader?.lastStep = leader?.currentAction
        leader!.currentAction = MXSOneAction(axle: leader!, type: .active)
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
    
    func responderReplyAction(reBlock:(_ can :Bool, _ pokers :Array<MXSPoker>?) -> Void) {
//        let action: PokerAction = self.leader!.currentAction!.action
//        if action == .warFire || action == .arrowes {
//            selectAllElseSelf()
//        }
        let responder_one = responder.first!
        if responder_one.pokers.count < 1 {
            reBlock(false, nil)
            return
        }
        let action_reply: PokerAction = self.leader!.currentAction!.reply.act
        MXSLog("opponter pokers: " + "\(responder_one.pokers)")
        let contain = responder_one.pokers.filter { poker in
            poker.actionGuise == action_reply
        }
        if contain.count > 0 {
            print(contain.first!)
            reBlock(true, [contain.first!])
        }
        else { reBlock(false, nil) }
    }
    
    func responderSufferConsequence(reBlock:(_ spoils :SpoilsType, _ pokers :Array<MXSPoker>?) -> Void) {
        let hero:MXSHero = responder.first!
        let action = MXSJudge.cmd.leader?.currentAction?.action
        switch action {
        case .unknown, .defense, .detect, .give, .none:
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
        case .recover:
            let _ = hero.plusHP()
            reBlock(.nothing, nil)
        }
    }
    
    
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
    
    
    //MARK: - for AI
    
    func returnMinHero() -> MXSHero {
//        let others = self.subject.filter { hero in
//            hero.cycleState == .blank
//        }
//        return others.first!
        print("Judge.subject: " + "\(self.subject)")
        let hero = self.subject.first { hero in
            hero.cycleState == .blank
        }
        return hero!
    }
}
