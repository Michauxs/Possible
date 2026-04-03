//
//  MXSOneAction.swift
//  Possible
//
//  Created by Sunfei on 2020/9/30.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit


enum ActionFensive {
    case offensive
    case defensive
}
enum ActionType {
    case unknown
//    case dealcards
    case alive//common act
    case endFunc//end note - 主动/被动全部完成
    case endLead//end note - 回合结束
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
        var type:Int = 0//0:not do anything  1:defensive  2:actuate
        var numb:Int = 0
        var color:PokerColor = .unknown
        var aFunc:PokerFunc = .unknown
        var count:Int = 0//
        var need_aim:Int = 0//type=2:
        
        func reset() {
            type = 0; numb = 0; color = .unknown; aFunc = .unknown; count = 0; need_aim = 0;
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
    
    weak var belong:MXSHero?
    /**攻守之势**/
    var fensive:ActionFensive = .offensive
    var categy:ActionType = .alive
    var skill:MXSSkill?
    
    var aimType:ActionAimType = .unknown
    var aim:[MXSHero] = [MXSHero]()
    
    var aFunc:PokerFunc = .unknown {
        didSet {
            if self.fensive == .offensive {
                reply.count = 1
                
                switch aFunc {
                case .unknown, .dodge, .detect:
                    reply.reset()
                    consequence.reset()
                    effect.reset()
                case .steal, .destroy:
                    reply.aFunc = .detect
                    aimType = .ptp
                case .attack:
                    reply.aFunc = .dodge
                    aimType = .ptp
                case .warFire:
                    reply.aFunc = .attack
                    aimType = .aoe
                case .arrowes:
                    reply.aFunc = .dodge
                    aimType = .aoe
                case .duel:
                    reply.aFunc = .attack
                    aimType = .ptp
                case .remedy:
                    reply.count = 0
                    reply.aFunc = .remedy
                    if aim.count == 0 {
                        aimType = .oneself
                    }
                    else {
                        aimType = .ptp
                    }
                case .give:
                    reply.count = 0
                    reply.aFunc = .give
                    //TODO: one -> group: several/multiple
                    aimType = .ptp
                case .JieDao:
                    reply.type = 2
                    reply.aFunc = .attack
                    reply.need_aim = 1
                }
            }
            else {
                //被动
                //TODO: 被主动
            }
            
            MXSLog(aimType, "this poker aimType: ")
        }
    }
    
    lazy var pokers:Array<MXSPoker> = Array<MXSPoker>()
    
    lazy var reply:ActionReply = ActionReply()
    lazy var effect:ActionEffect = ActionEffect()
    lazy var consequence:ActionConsequence = ActionConsequence()
    
    var aimMax:Int = 1
    func aimAppend(_ hero:MXSHero) {
        if aim.contains(where: { one in one === hero }) { return }
        
        if aim.count >= aimMax { //腾出位置，加新
            let first = aim.remove(at: 0)
            first.signStatus = .blank
        }
        hero.signStatus = .selected
        aim.append(hero)
    }
        
    func aimRemove(_ hero:MXSHero) {
        if let index = aim.firstIndex(where: { one in one === hero }) {
            let hero = aim.remove(at: index)
            hero.signStatus = .blank
            
//            if aFunc == .remedy {
//                aimType = aim.count == 0 ? .oneself : .ptp
//            }
        }
    }
    
    func aimClear() {
        for note in aim {
            note.signStatus = .blank
        }
        aim.removeAll()
    }
    
    func reset() {
        reply.reset()
        consequence.reset()
        effect.reset()
        aFunc = .unknown
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
