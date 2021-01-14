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
            leader?.isActive = true
            active = leader
        }
    }
    func leaderReactive() {
        for one in passive { one.isActive = false }
        passive.removeAll()
        leader?.isActive = true
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
        for one in passive { one.isActive = false; one.isBeAimed = false}
        passive.removeAll()
        
        flowNote += 1
        let hero = subject[flowNote]
        self.leader = hero
    }
    
    //MARK: - passive
    var passive:Array<MXSHero> = Array<MXSHero>()
    func appendOrRemovePassive(_ someone:MXSHero) {
        if let index = passive.firstIndex(where: {$0 === someone}) {
            let one = passive.remove(at: index)
            one.isBeAimed = false
        }
        else {
            passive.append(someone)
            someone.isBeAimed = true
        }
    }
    
    func clearPassive(){
        for one in passive {
            one.isBeAimed = false
        }
        passive.removeAll()
    }
    
    
    func opponentActive() {
        if passive.count == 1 {
            let hero = passive.first!
            hero.isActive = true
            leader?.isActive = false
        }
    }
    
    func selectAllElseSelf() {
        for one in passive { one.isActive = false; one.isBeAimed = false}
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
