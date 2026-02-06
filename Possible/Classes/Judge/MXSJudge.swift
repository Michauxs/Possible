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
    
    
    //MARK: - leader cycle
    var flowNote:Int = -1 {
        didSet {
            if flowNote == self.subject.count {
                flowNote = 0
            }
        }
    }
    
    func dealcardForGameStart(ready:(_ heroArray: [MXSHero], _ pokersArray: [[MXSPoker]]) -> Void) {
        var pokers_array = [[MXSPoker]]()
        for hero in subject {
            let pokers = MXSPokerCmd.shared.push(4)
            hero.getPokers(pokers)
            pokers_array.append(pokers)
        }
        
        ready(subject, pokers_array)
    }
    func gameOver() {
        leader = nil
        flowNote = -1
        diary.removeAll()
        subject.removeAll()
//        responder.removeAll()
    }
    
    func turnLeaderAndDealcard(reBlock:(_ leader: MXSHero, _ pokers: [MXSPoker]?) -> Void) {
        
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
        self.leaderReactive()
        
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
        
        let action:PokerFunc = leader!.holdAction!.aFunc
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
    
    
    func record(pokers:[MXSPoker], toAction holdAction:MXSOneAction) {
        leader?.holdAction?.pokers.append(contentsOf: leader!.picked)
        
        MXSLog(leader?.holdAction?.pokers as Any, "action note pokers")
    }
        
    func leaderReactive() {
        leader!.signStatus = .active
        leader!.holdAction = MXSOneAction(axle: leader!, fensive: .offensive)
    }
    
    
    //MARK: - responder
    var reqHeroStack:[MXSHero] = []
    
    func currentResponderDone() {
        guard let hero = reqHeroStack.popLast() else { return }
        hero.signStatus = .blank
        
        MXSLog("one opponter done -> goon")
    }
    
    var responder:[MXSHero] {
        get {
            let undone = leader?.holdAction?.aim.filter({$0.done == false})
            var tmp = [MXSHero]()
            for undo in undone! {
                tmp.append(undo.hero!)
            }
            MXSLog(tmp, "JudgeCmd.get responder: ")
            return tmp
        }
    }
    
    var leader:MXSHero?
    var activer:MXSHero?
    var replyer:MXSHero?
    /*------------ 触动链 ---------------*/
    
    func findResponder() -> MXSHero? {
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
    
    
    func responderGainPoker(_ pokers:[MXSPoker]) -> Void {
        let responder_one = responder.first!
        responder_one.getPokers(pokers)
        responder_one.holdHisPokersView(pokers) {
            
        }
    }
    
    //MARK: - 检查/修正一些 操作上不需要，规则上需要自动添加的信息
    func correctHoldAction(action:MXSOneAction) {
        /**需要补充的**/
        if action.aimType == .aoe || action.aimType == .all {
            
            action.aimClear()
            
            var byone = action.aimType == .all ? 0 : 1
            while byone < subject.count {
                let next_index = (flowNote + byone)%subject.count
                let hero = subject[next_index]
                
                action.aimAppend(hero)
                
                byone+=1
            }
            MXSLog("MXSJudge ----------------------> leader call group")
        }
        
        //未指定=指定自己
        if action.aFunc == .remedy && action.aim.count == 0 {
            MXSLog(self.leader!.name, "remedy self")
            action.aimAppend(leader!)
        }
        
        self.diary.append(action)
        
        //压栈
        var tmp = [MXSHero]()
        for item in action.aim {
            tmp.append(item.hero!)
        }
        reqHeroStack.append(contentsOf: tmp.reversed())
    }
    
    //MARK: - judge
    func canDefence() -> Bool {
        let action_reply: PokerFunc = self.leader!.holdAction!.reply.act
        let responder_one = responder.first!
        MXSLog(action_reply, "attack's reply action")
        MXSLog(responder_one.holdAction?.aFunc as Any, "defence action")
        return responder_one.holdAction?.aFunc == action_reply
    }
    
    func distance(from:MXSHero, to:MXSHero) -> Int {
        let d1 = abs(from.seq - to.seq)
        let d2 = abs(self.subject.count - d1)
        return d1<d2 ? d1 : d2
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
