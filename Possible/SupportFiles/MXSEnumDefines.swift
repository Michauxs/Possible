//
//  MXSMenuDefines.swift
//  Possible
//
//  Created by Sunfei on 2020/8/19.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit


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

let indexHeroName: Int = 0
let indexHeroPhoto: Int = 1
let indexHeroHP: Int = 2
let indexHeroSKFate: Int = 3
let indexHeroDesc: Int = 4

let indexSkillName: Int = 0
let indexSkillPhoto: Int = 1
let indexSkillPower: Int = 2
let indexSkillMode: Int = 3
let indexSkillDesc: Int = 4

//MARK:- Poker
enum PokerColor : Int {
    case heart = 0
    case spade
    case club
    case diamond
}

enum PokerState : Int {
    case pass = 0
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
    case recover
}

enum ActionReplyResult : Int {
    case complete = 1
    case bear
    case NA
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
    case unused = 0
    /**被动 不可操作*/
    case keepOn
    /**关闭*/
    case unable
    /**开启*/
    case enable
    /**开启后 持续生效*/
    case staring
}

