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
     *
     *
     */
    
    var subject:Array<MXSHero> = Array<MXSHero>()
    /**[hero action pokeres]*/
    var diary:Array<MXSOneAction> = Array<MXSOneAction>()
    /***/
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
    var active:MXSHero?
    var passive:Array<MXSHero> = Array<MXSHero>()
    func appendOrRemovePassive(_ someone:MXSHero) {
        if let index = passive.firstIndex(where: {$0 === someone}) {
            let one = passive.remove(at: index)
            one.isBeAimed = false
        }
        else {
            passive.append(someone)
            someone.isBeAimed = false
        }
    }
    func clearPassive(){
        for one in passive {
            one.isBeAimed = false
        }
        passive.removeAll()
    }
    
    var flowNote:Int = -1 {
        didSet {
            print("did set flow note")
            if flowNote == subject.count {
                print("reset flow note 0")
                flowNote = 0
            }
        }
    }
    
    static let cmd : MXSJudge = {
        let single = MXSJudge.init()
        return single
    }()
    
    func next() {
        for one in passive { one.isActive = false; one.isBeAimed = false}
        passive.removeAll()
        
        flowNote += 1
        let hero = subject[flowNote]
        self.leader = hero
    }
    
    func opponentActive() {
        if passive.count == 1 {
            let hero = passive.first!
            hero.isActive = true
            leader?.isActive = false
        }
    }
    func leaderReactive() {
        for one in passive { one.isActive = false }
        passive.removeAll()
        leader?.isActive = true
    }
    
    func selectAllElseSelf() {
        for one in passive { one.isActive = false; one.isBeAimed = false}
        passive.removeAll()
        
        for hero in subject {
            if hero === leader { continue }
            passive.append(hero)
        }
    }
    
}
