//
//  MXSJudge.swift
//  Possible
//
//  Created by Sunfei on 2020/9/30.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit
import Foundation

class HeroDoneNote {
    var from:MXSHero = MXSHeroCmd.shared.getNewBlankHero()
    var recver:MXSHero = MXSHeroCmd.shared.getNewBlankHero()
    weak var action:MXSOneAction?
    
    init() {
        
    }
    init(from: MXSHero, recver: MXSHero, action: MXSOneAction) {
        self.from = from
        self.recver = recver
        self.action = action
    }
}

class MXSJudge {
    /**  ==> leader ==>
     * | -------------> |
     * |    压栈/出栈    |
     * |<-------------- |
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
            leader!.endRound()
            
        }
        
        self.flowNote += 1
        MXSLog("--------------------------")
        MXSLog(flowNote, "Did set flow note:")
        let hero = subject[flowNote]
        
        self.leader = hero
        self.leader?.active()
        
        let pokers = MXSPokerCmd.shared.push(leader!.collectNumb)
        leader!.getPokers(pokers)
        
        reBlock(leader!, pokers)
    }
    
    // TODO: leader被回转指定 1.待响应栈有/无
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
        
        if leader?.holdAction?.aim.count == 0 { //no aim
            if action == .remedy && leader!.HPCurrent < leader!.HPSum { return true }
            
        }
        else {
            let aim_first = leader?.holdAction?.aim.first
            if action == .attack {
                return leader!.attackCount < leader!.attackLimit
            }
            if action == .duel {
                return true
            }
            if (action == .steal || action == .destroy) && aim_first!.ownPokers.count > 0 {
                return true
            }
            if action == .remedy && aim_first!.HPCurrent < aim_first!.HPSum  {
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
        leader!.reActive()
    }
    
    
    //MARK: - responder
    func currentResponderDone() {
        guard let act = replyStack.popLast() else { return }
        act.recver.signStatus = .blank
        
        MXSLog("one opponter done -> goon")
    }
    
    
    var leader:MXSHero?
    
    func findResponder() -> MXSHero? {
        var hero:MXSHero?
        if MXSJudge.cmd.replyStack.count > 0 {
            let act = MXSJudge.cmd.replyStack.last!
            hero = act.recver
            hero?.asRecver()
        }
        return hero
    }
    
    func aimHavingPoker() -> Bool {
        return self.currentRecver.ownPokers.count > 0
    }
    
    
    func responderGainPoker(_ pokers:[MXSPoker]) -> Void {
        let responder_one = self.currentRecver
        responder_one.getPokers(pokers)
        responder_one.holdHisPokersView(pokers) {
            
        }
    }
    
    var replyStack:[HeroDoneNote] = [HeroDoneNote]()
    var currentRecver:MXSHero {
        get {
            replyStack.last?.recver ?? MXSHeroCmd.shared.getNewBlankHero()
        }
    }
    var currentActiver:MXSHero {
        get {
            replyStack.last?.from ?? MXSHeroCmd.shared.getNewBlankHero()
        }
    }
    //MARK: - 检查/修正一些 操作上不需要，规则上需要自动添加的信息
    //ps:仅主动操作时使用
    //TODO: - 被动
    func correctHoldAction(action:MXSOneAction) {
        /**需要补充的**/
        if action.aimType == .aoe || action.aimType == .all {
            action.aimClear()
            //清除重新按序号加入全体（是否包含leader）
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
        
        //压栈
        var tmp = [HeroDoneNote]()
        for item in action.aim {
            tmp.append(HeroDoneNote(from: action.belong!, recver: item, action: action))
        }
        replyStack.append(contentsOf: tmp.reversed())
    }
    
    //MARK: - judge
    func canDefence() -> Bool {
        let action_reply: PokerFunc = self.currentActiver.holdAction!.reply.aFunc
        let responder_one = self.currentRecver
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
