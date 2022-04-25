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
enum ActionType {
    case active
    case reply
}
enum ActionCategy {
    case single
    case group
    case oneself
    case endLead
}

enum EffectType {
    case unknown
    case hp
    case poker
//    case attackCount
}

class MXSOneAction {
    
    class ActionReply {
        var type:Int = 0//0:do  1:not do anything
        var numb:Int = 0
        var color:PokerColor = .unknown
        var act:PokerAction = .unknown
        var count:Int = 0//
        
        func reset() {
            type = 0; numb = 0; color = .unknown; act = .unknown; count = 0;
        }
    }
    class ActionEffect {
        var type:EffectType = .unknown
        var numb:Int = 0
        var count:Int = 0
    }
    class ActionConsequence {
        
    }
    
    var cycleSign:CycleType = .start
    
    weak var belong:MXSHero?
    var type:ActionType = .active
    var categy:ActionCategy = .single
    var skill:MXSSkill?
    var action:PokerAction = .unknown {
        didSet {
            switch action {
            case .unknown, .defense, .detect, .recover, .gain:
                reply.reset()
            case .steal, .destroy:
                reply.count = 1
                reply.act = .detect
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
            case .remedy:
                reply.count = 0
                reply.act = .recover
            case .give:
                reply.count = 0
                reply.act = .gain
            }
            
            if action == .warFire || action == .arrowes {
                categy = .group
            }
            else { categy = .single }
        }
    }
    lazy var pokers:Array<MXSPoker> = Array<MXSPoker>()
    lazy var aim:Array<MXSHero> = Array<MXSHero>()
    lazy var reply:ActionReply = ActionReply()
    lazy var effect:ActionEffect = ActionEffect()
    lazy var consequence:ActionConsequence = ActionConsequence()
    
    func reset() {
        reply.reset()
        action = .unknown
        pokers.removeAll()
    }
    
    //MARK: - init
    init() {
        
    }
    init(axle:MXSHero, type:ActionType) {
        self.belong = axle
        self.type = type
    }
    
    
}
