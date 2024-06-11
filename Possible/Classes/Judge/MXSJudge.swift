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
    
    var subject:[MXSHero] = [MXSHero]()
    /**hero action pokeres aim?  /hp  /cycle  */
    var diary:[MXSOneAction] = [MXSOneAction]()
    weak var desktop :MXSGroundController?
    
    //MARK: - intermediary
    func appendResponder(_ hero:MXSHero) {
        hero.signStatus = .selected
        self.responder.append(hero)
//        leader?.holdAction?.aim.append(hero)
    }
    func removeResponder(_ hero:MXSHero) {
        if let index = self.responder.firstIndex(where: { one in hero.name == one.name }) {
            hero.signStatus = .blank
            self.responder.remove(at: index)
//            leader?.holdAction?.aim.remove(at: index)
        }
    }
    
    func clearResponder() {
        self.responder.removeAll()
        leader?.holdAction?.aim.removeAll()
    }
    
    //MARK: - leader cycle
    var flowNote:Int = -1 {
        didSet {
            if flowNote == self.subject.count {
                flowNote = 0
            }
        }
    }
    
    var leader:MXSHero? {
        didSet {
            leader?.holdAction = MXSOneAction(axle: leader!, fensive: .offensive)
            leader?.signStatus = .active
        }
    }
    func dealcardForGameStart(offensive:(_ hero:MXSHero)->Void) {
        for hero in subject {
            let pokers = MXSPokerCmd.shared.push(4)
            hero.getPokers(pokers)
            hero.GraspView?.collectPoker(pokers)
            hero.concreteView?.getPokerAnimate(pokers, complete: {
                hero.concreteView?.pokerCount = hero.ownPokers.count
            })
        }
        dealcardForNextLeader { hero, pokers in
            offensive(hero)
        }
    }
    func gameOver() {
        leader = nil
        flowNote = -1
        diary.removeAll()
        subject.removeAll()
        responder.removeAll()
    }
    
    func dealcardForNextLeader(reBlock:(_ hero :MXSHero, _ pokers :[MXSPoker]?) -> Void) {
        
        if leader != nil {
            leader!.endActiveByClearStatus()
            
            leader!.holdAction!.categy = .endLead //note end lead
            diary.append(leader!.holdAction!)
        }
        
        self.flowNote += 1
        MXSLog("--------------------------")
        MXSLog(flowNote, "Did set flow note:")
        let hero = subject[flowNote]
        self.leader = hero
        
        let pokers = MXSPokerCmd.shared.push(leader!.collectNumb)
        leader!.getPokers(pokers)
        leader!.GraspView?.collectPoker(pokers)
        leader!.concreteView?.getPokerAnimate(pokers, complete: {
            self.leader!.concreteView?.pokerCount = self.leader!.ownPokers.count
        })
        
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
        
        if (action == .warFire || action == .arrowes) { return true }
        
        if responder.count == 0 { //no aim
            if action == .remedy && leader!.HPCurrent < leader!.HPSum { return true }
            
        }
        else {
            if action == .attack {
                return leader!.attackCount < leader!.attackLimit
            }
            if action == .duel {
                return true
            }
            if (action == .steal || action == .destroy) && responder.first!.ownPokers.count > 0 {
                return true
            }
            if action == .remedy && responder.first!.HPCurrent < responder.first!.HPSum  {
                return true
            }
        }
        
        return false
    }
    
    
    func record(discardPokers pokers:[MXSPoker], toAction holdAction:MXSOneAction) {
        leader?.holdAction?.pokers.append(contentsOf: leader!.picked)
        MXSLog(leader?.holdAction?.pokers as Any, "action note pokers")
    }
    func leaderReactive() {
        clearResponder()
        leader?.signStatus = .active
        
        leader!.holdAction = MXSOneAction(axle: leader!, fensive: .offensive)
    }
    
    /**⚠️默认不包括自己**/
    func selectAllPlayer(exceptSelf:Bool = true) {
//        let others = self.subject.filter { hero in
//            //hero.cycleState == .blank
//        }
        
        responder.removeAll()
        
        var byone = 0
        var except:Int = 0
        if exceptSelf { except = 1 }
        while byone < subject.count-except {
            let next_index = (flowNote + byone + 1)%subject.count
            let hero = subject[next_index]
            responder.append(hero)
            
            hero.signStatus = .selected
            
            byone+=1
        }
        MXSLog("MXSJudge ----------------------> leader call group")
    }
    func responderHaveReplyed() {
        let hero:MXSHero = responder.first!
        hero.signStatus = .blank
        self.responder.removeFirst()
        
        MXSLog("one opponter done -> goon")
    }
    
    //MARK: - responder
    var responder:[MXSHero] = [MXSHero]()
    var activer:MXSHero?
    var replyer:MXSHero?
    /*------------ 触动链 --------------- 230719：可能不需要触动链，触动激活是临时的，只需记录当前正在对峙的双方
     Activer <-note | aim-> Replyer <-note | next-> Next ...
     */
    
    func pleaseResponderReply() -> MXSHero? {
        var hero:MXSHero?
        if MXSJudge.cmd.responder.count > 0 {
            hero = MXSJudge.cmd.responder.first!
            hero!.holdAction = MXSOneAction(axle: hero!, fensive: .defensive)
        }
        return hero
    }
    
    func aimHavingPoker() -> Bool {
        let hero = responder.first!
        return hero.ownPokers.count > 0
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
    
    func responderSufferConsequence(reBlock:HeroSufferResult) {
        //let conseq = leader?.holdAction?.consequence
        let hero:MXSHero = responder.first!
        
        let action = MXSJudge.cmd.leader?.holdAction?.action
        switch action {
        case .unknown, .dodge, .detect, .give, .recover, .gain, .remedy:
            reBlock(.nothing, nil, nil)
            
        case .attack, .warFire, .arrowes, .duel:
            hero.minsHP()
            reBlock(.injured, nil, nil)
            
        case .steal:
            let random = hero.rollRandomPoker()
            MXSLog(random, "The poker will comefrom ")
            hero.losePokers([random])
            MXSJudge.cmd.leader?.getPokers([random])
            reBlock(.wrest, [random], .awayfrom)
            
        case .destroy:
            let random = hero.rollRandomPoker()
            hero.losePokers([random])
            reBlock(.destroy, [random], .passed)
            
        case .none:
            break
        }
        
    }
    
    func responderGainPoker(_ pokers:[MXSPoker]) -> Void {
        let responder_one = responder.first!
        responder_one.getPokers(pokers)
        responder_one.GraspView?.collectPoker(pokers)
        responder_one.concreteView?.getPokerAnimate(pokers, complete: {
            responder_one.concreteView?.pokerCount = responder_one.ownPokers.count
        })
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
        MXSLog("Judge.subject: " + "\(self.subject)", "choose aim at")
//        let hero = self.subject.first { hero in
//            hero.cycleState == .blank
//        }
        
        var next = flowNote+1
        if next == subject.count { next = 0 }
        let hero = subject[next]
        
        MXSLog(hero.name as String, "AI aim at hero")
        return hero
    }
}
