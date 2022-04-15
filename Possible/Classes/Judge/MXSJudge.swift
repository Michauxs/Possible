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
     * |      --------cycle------>      |
     * |
     * |  leader <- active -> _passive_ |
     * |
     * |      <-------cycle-------      |
     */
    
    static func translateHeroModel(_ model:MXSHero) -> Dictionary<String, Any> {
        return ["name":""]
    }
    static func translateHeroModelArray(_ model:Array<MXSHero>) -> Array<Dictionary<String, Any>> {
        return [["name":""]]
    }
    
    static let cmd : MXSJudge = {
        let single = MXSJudge.init()
        return single
    }()
    
    var subject:Array<MXSHero> = Array<MXSHero>()
    /**hero action pokeres aim?  /hp  /cycle  */
    var diary:Array<MXSOneAction> = Array<MXSOneAction>()
    
    //MARK: - leader
    var leaderActiveAction:PokerAction?
    var leaderActiveDiscard:Array<MXSPoker>?
    var leader:MXSHero? {
        willSet {
            passive.removeAll()
            leader?.endActiveAndClearHistory()
        }
        didSet {
            if leader != nil {
                leader!.currentAction = MXSOneAction(axle: leader!)
                leader!.signStatus = .active
                active = leader
            }
        }
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
        
        if passive.count == 0 { //no aim
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
            if (action == .steal || action == .destroy) && passive.first!.pokers.count > 0 {
                return true
            }
            if action == .recover && passive.first!.HPCurrent < passive.first!.HPSum  {
                return true
            }
        }
        
        return false
    }
    func leaderReactive() {
        for one in passive { one.signStatus = .blank }
        passive.removeAll()
        leader?.signStatus = .active
    }
    
    func leaderDiscard(poker:Array<MXSPoker>, action:PokerAction) {
        let one = MXSOneAction(someone: leader!, act: action, pok: poker, to: passive)
        diary.append(one)
    }
    
    func findHistoryPoker() -> Array<MXSPoker> {
        for index in 0...diary.count {
            let last = diary[diary.count - index]
            if last.hero === leader {
                return last.pokers
            }
        }
        return Array<MXSPoker>()
    }
//    func oppoentDiscard(poker:Array<MXSPoker>, action:PokerAction) {
//
//    }
    
    //MARK: - active
    var active:MXSHero?
    
    var flowNote:Int = -1 {
        didSet {
            print("did set flow note")
            if flowNote == subject.count {
                print("reset flow note 0")
                flowNote = 0
            }
        }
    }
    func next() {
        for one in passive { one.signStatus = .blank}
        passive.removeAll()
        
        flowNote += 1
        let hero = subject[flowNote]
        self.leader = hero
    }
    
    //MARK: - passive
    var passive:Array<MXSHero> = Array<MXSHero>()
    
    func passiveCanDefense(pokerBlock:(String) -> Void) -> Bool {
        if passive.count < 1 {
            return false
        }
        
        pokerBlock("s")
        
        let passive_one = passive.first!
        if passive_one.pickes.count < 1 { return false }
        
        let action_pick: PokerAction = passive_one.pickes.first!.actionGuise
        
        let action_attck: PokerAction = self.leader!.currentAction!.action
        
        var action_reply: PokerAction?
        if action_attck == .attack || action_attck == .arrowes {
            action_reply = .defense
        }
        else if action_attck == .steal || action_attck == .destroy {
            action_reply = .detect
        }
        else if action_attck == .warFire {
            action_reply = .attack
        }
        else {
            action_reply = .unknown
        }
        
        return action_reply == action_pick
    }
    
    func addPassive(_ someone:MXSHero) {
        passive.append(someone)
    }
    func removePassive(_ someone:MXSHero) {
        if let index = passive.firstIndex(where: {$0 === someone}) {
            let one = passive.remove(at: index)
        }
    }
    
    func appendOrRemovePassive(_ someone:MXSHero) {
        if let index = passive.firstIndex(where: {$0 === someone}) {
            let one = passive.remove(at: index)
            one.signStatus = .blank
        }
        else {
            passive.append(someone)
            someone.signStatus = .selected
        }
    }
    
    func clearPassive(){
        for one in passive {
            one.signStatus = .blank
        }
        passive.removeAll()
    }
    
    
    func opponentActive() {
        if passive.count == 1 {
            let hero = passive.first!
            hero.signStatus = .active
            leader?.signStatus = .blank
        }
    }
    
    func selectAllElseSelf() {
        for one in passive { one.signStatus = .blank}
        passive.removeAll()
        /**先清除再添加 = 顺序加入*/
        for hero in subject {
            if hero === leader { continue }
            passive.append(hero)
        }
        /**
         for hero in subject {
             if hero === leader  || passive.contains(where: {$0 === hero}) { continue }
             passive.append(hero)
         }
         */
    }
    
}
