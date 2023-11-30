//
//  MXSOneAction.swift
//  Possible
//
//  Created by Sunfei on 2020/9/30.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit

enum CycleType : String {
    case start = "start"
    case end = "end"
}
enum ActionFensive {
    case offensive
    case defensive
}
enum ActionCategy {
    case unknown
    case alive//common act
    case endLead//end note
}

enum EffectType {
    case unknown
    case hp
    case poker
//    case attackCount
}
enum ConsequenceType {
    case unknown
    case none
    case buff
    case hp
    case poker
}
enum ActionAimType {
    case unknown
    case oneself
    case ptp
    case aoe
    case all//
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
        var count:Int = 0
        
        func reset() {
            type = .unknown; count = 0;
        }
    }
    class ActionConsequence {
        var type:ConsequenceType = .unknown
        var count:Int = 0
        
        func reset() {
            type = .unknown; count = 0;
        }
    }
    
    var cycleSign:CycleType = .start
    
    weak var belong:MXSHero?
    var fensive:ActionFensive = .offensive
    var categy:ActionCategy = .alive
    var aimType:ActionAimType = .unknown
    var skill:MXSSkill?
    var action:PokerAction = .unknown {
        didSet {
            switch action {
            case .unknown, .dodge, .detect, .recover, .gain:
                reply.reset()
                consequence.reset()
                effect.reset()
            case .steal, .destroy:
                reply.count = 1
                reply.act = .detect
                aimType = .ptp
            case .attack:
                reply.count = 1
                reply.act = .dodge
                aimType = .ptp
            case .warFire:
                reply.count = 1
                reply.act = .attack
                aimType = .aoe
            case .arrowes:
                reply.count = 1
                reply.act = .dodge
                aimType = .aoe
            case .duel:
                reply.count = 1
                reply.act = .attack
                aimType = .ptp
            case .remedy:
                reply.count = 0
                reply.act = .recover
                aimType = .ptp
            case .give:
                reply.count = 0
                reply.act = .gain
                //TODO: one -> group: several/multiple
                aimType = .ptp
            }
            
        }
    }
    lazy var pokers:Array<MXSPoker> = Array<MXSPoker>()
    lazy var aim:Array<MXSHero> = Array<MXSHero>()
    
    lazy var reply:ActionReply = ActionReply()
    lazy var effect:ActionEffect = ActionEffect()
    lazy var consequence:ActionConsequence = ActionConsequence()
    
    func reset() {
        reply.reset()
        consequence.reset()
        effect.reset()
        action = .unknown
        pokers.removeAll()
    }
    
    //MARK: - init
    init() {
        
    }
    init(axle:MXSHero, fensive:ActionFensive) {
        self.belong = axle
        self.fensive = fensive
    }
    
    
}
