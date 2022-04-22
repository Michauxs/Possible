//
//  MXSMenuDefines.swift
//  Possible
//
//  Created by Sunfei on 2020/8/19.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit

func MXSLog(_ args:Any, _ sign:String = "MXSSwift") {
    #if DEBUG
        print(Date.init(), sign, ":", args)
    #endif
}
func printPointer<T>(ptr: UnsafePointer<T>, _ sign:String="Possible") {
    print(sign)
    print(ptr)
}

let kMessageType: String = "develop_message_type"
let kMessageValue: String = "develop_message_value"


let kSkill: String = "key_skill"
let kSkillPhoto: String = "key_skill_photo"
let kSkillName: String = "key_skill_name"
let kSkilles: String = "key_skill_array"
let kSkillesAssem: String = "key_skill_assem_array"

let kHero: String = "key_hero"
let kHeroName: String = "key_hero_name"
let kHeroPhoto: String = "key_hero_photo"

let SkillBlankPhoto: String = "skill_002"


let FontKaiTiBold: String = "Kaiti SC"
let FontKaiTiRegular: String = "KaiTi_GB2312"
let FontXingKai: String = "FZXingKai-S04S"


let kStringName: String = "name"
let kStringImage: String = "image"
let kStringHP: String = "hp"
let kStringSKFate: String = "skill_fate"
let kStringDesc: String = "desc"

let kStringSkillPower: String = "power"
let kStringSkillMode: String = "mode"
let kStringUnknown: String = "Unknown"


//MARK:- Hero
enum PickHeroType {
    case PVE
    case PVP
}

//主动/被选择/等待操作
enum HeroSignStatus {
    case blank
    case active
    case selected
    case focus
}
//MARK:- Poker
enum PokerColor : Int {
    case unknown = 0
    case heart
    case spade
    case club
    case diamond
}

enum PokerState : Int {
    case unknown = 0
    case pass
    case ready
    case handOn
    case transferring
}

enum PokerAction : Int {
    case unknown = 0
    case attack = 1
    case defense
    case warFire
    case arrowes
    case duel
    case steal
    case destroy
    case detect
    case remedy
    case recover
    case give
    case gain
}

//MARK:- Skill
enum SkillPower : Int {
    case unKnown = 0
    case lock
    case blank
    case redToAttack = 10
    case attackTwoTwiceMaybe = 11
    case WolfSt = 12
    case drink
    case allIsMy = 14
    case attackOrDefense
    case control = 16
    case exchange = 17
    case againPrev = 18
    case amazing = 19
    case giving = 21
    case blackDestory = 22
    case defenseAward = 23
    case defenseAward2 = 24
    case transAttack = 25
    case transInjured = 26
    case needDoubleDefense
    case minsDoubleHP
}

enum SkillState : Int {
    case unknown = 0
    case unused
    /**被动 不可操作*/
    case keepOn
    /**关闭*/
    case unable
    /**开启*/
    case enable
    /**开启后 持续生效*/
    case staring
}
enum SkillMode : Int {
    case unknown = 0
    /**主动*/
    case active = 1
    /**被动*/
    case possive = 2
    /**触发式*/
    case triggerWillGetPok = 10
    
    case triggerWillAttack = 15
    case triggerDoneAttack = 16
    case triggerDefAttack = 17
    
    case triggerWillDefence = 20
    case triggerDoneDefence = 21
    
    case triggerInjured = 25
    case triggerRecovery = 30
}


enum SpoilsType {
    case nothing
    case destroy
    case wrest
    case gain
}

enum DiscardPokerType : Int {
    case passed = 0
    case handover
}
enum ReplyResultType : Int {
    case nothing = 0
    case success
    case failed
    case gain
}

enum CycleState {
    case blank
    case leader
    case responder
    case active
}
