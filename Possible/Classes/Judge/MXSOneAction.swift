//
//  MXSOneAction.swift
//  Possible
//
//  Created by Sunfei on 2020/9/30.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit

enum CycleType : String{
    case start = "start"
    case end = "end"
}
enum OneStepType {
    case unknown
    case seplier
    case aimOther
    case oneself
}


class MXSOneAction {
    
    class ActionReply {
        var type:Int = 0//0:do  1:not do anything
        var numb:Int = 0
        var color:PokerColor = .unknown
        var act:PokerAction = .unknown
        var count:Int = 0
        
        func reset() {
            type = 0; numb = 0; color = .unknown; act = .unknown; count = 0;
        }
    }
    class ActionEffect {
        var type:Int = 0
        var numb:Int = 0
        var count:Int = 0
    }
    
    var cycleSign:CycleType = .start
    
    weak var hero:MXSHero?
    var skill:MXSSkill?
    var action:PokerAction = .unknown {
        didSet {
            switch action {
            case .unknown, .defense, .steal, .destroy, .detect, .recover:
                reply.reset()
            case .attack:
                reply.count = 1
                reply.act = .defense
            case .warFire:
                reply.count = 1
                reply.act = .attack
            case .arrowes:
                reply.count = 1
                reply.act = .defense
            case .duel:
                reply.count = 1
                reply.act = .attack
            }
        }
    }
    lazy var pokers:Array<MXSPoker> = Array<MXSPoker>()
    lazy var aim:Array<MXSHero> = Array<MXSHero>()
    lazy var reply:ActionReply = ActionReply()
    
    
    func reset() {
        reply.reset()
        action = .unknown
        pokers.removeAll()
    }
    
    //MARK: - init
    init() {
        
    }
    init(axle:MXSHero) {
        hero = axle
    }
    
    init(someone:MXSHero, act:PokerAction, pok:Array<MXSPoker>, to:Array<MXSHero>) {
        hero = someone
        action = act
        pokers = pok
        aim = to
    }
    
    init(someone:MXSHero, act:PokerAction, pok:Array<MXSPoker>) {
        hero = someone
        action = act
        pokers = pok
    }
    
    init(someone:MXSHero, HPChange:Int) {
        hero = someone
    }
    
    /** cycle:
     *0 - start
     *1 - end     */
    init(someone:MXSHero, cycle:CycleType) {
        hero = someone
        cycleSign = cycle
    }
    
}
