//
//  MXSOneAction.swift
//  Possible
//
//  Created by Sunfei on 2020/9/30.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit

class MXSOneAction {
    var hero:MXSHero?
    var action:PokerAction = .unknown
    var pokers:Array<MXSPoker> = Array<MXSPoker>()
    var aim:Array<MXSHero> = Array<MXSHero>()
    
    init(someone:MXSHero, act:PokerAction, pok:Array<MXSPoker>) {
        hero = someone
        action = act
        pokers = pok
    }
    
    init(someone:MXSHero, act:PokerAction, pok:Array<MXSPoker>, to:Array<MXSHero>) {
        hero = someone
        action = act
        pokers = pok
        aim = to
    }
}
