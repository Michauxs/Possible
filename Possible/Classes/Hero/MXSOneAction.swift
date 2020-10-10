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

class MXSOneAction {
    
    var hero:MXSHero?
    var action:PokerAction = .unknown
    var pokers:Array<MXSPoker> = Array<MXSPoker>()
    var aim:Array<MXSHero> = Array<MXSHero>()
    var cycleSign:CycleType = .start
    
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
