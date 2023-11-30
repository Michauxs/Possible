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
            hero.getPokers(MXSPokerCmd.shared.push(4))
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
    func theHeroHasReplyed() {
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
    
    func AIReplyAsResponder(reBlock:(_ type :ParryType, _ pokers:[MXSPoker]?) -> Void) {
        
        let action_reply: PokerAction = self.leader!.holdAction!.reply.act
        if let responder_one = responder.first { //expect
            responder_one.holdAction = MXSOneAction(axle: responder_one, fensive: .defensive)
            diary.append(responder_one.holdAction!)
            
            if action_reply == .recover {
                let _ = responder_one.plusHP()
                reBlock(.unneed, nil)
            }
            else if action_reply == .gain {
                responder_one.getPokers(leader!.holdAction!.pokers)
                reBlock(.gain, leader?.holdAction?.pokers)
            }
            else {// need
                
                if let idx = responder_one.ownPokers.firstIndex(where: { poker in
                    poker.actionGuise == action_reply
                }) {
                    let contain = responder_one.ownPokers[idx]
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
            
            let categy = self.leader!.holdAction!.aimType
            if categy == .aoe {
                self.selectAllPlayer()
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
    
    func responderSufferConsequence(reBlock:(_ spoils :SpoilsType, _ pokers :[MXSPoker]?) -> Void) {
        //let conseq = leader?.holdAction?.consequence
        let hero:MXSHero = responder.first!
        
        let action = MXSJudge.cmd.leader?.holdAction?.action
        switch action {
        case .unknown, .dodge, .detect, .give, .recover, .gain:
            reBlock(.nothing, nil)
            
        case .attack, .warFire, .arrowes, .duel:
            hero.minsHP()
            reBlock(.injured, nil)
            
        case .steal:
            let random = hero.rollRandomPoker()
            MXSLog(random, "The poker will handover")
            hero.losePokers([random])
            MXSJudge.cmd.leader?.getPokers([random])
            reBlock(.wrest, [random])
            
        case .destroy:
            let random = hero.rollRandomPoker()
            hero.losePokers([random])
            reBlock(.destroy, [random])
            
        case .remedy:
            let _ = hero.plusHP()
            reBlock(.recover, nil)
            
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
