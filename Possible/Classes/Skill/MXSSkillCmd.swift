//
//  MXSSkillCmd.swift
//  Possible
//
//  Created by Sunfei on 2020/8/24.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit

class MXSSkill {
    
    var name: String?
    var power: SkillPower = .unKnown
    var state: SkillState = .unused {
        didSet {
            
        }
    }
    var quality: Int?
    var desc: String?
    var photo: String?
    
    var attribute:Array<Any> = MXSSkillCmd.shared.signetData[SkillBlankPhoto]!
    
    func resetAttr() {
        attribute = MXSSkillCmd.shared.signetData[SkillBlankPhoto]!
    }
    
    //["name", "skill_000", 0, "desc"]
    init(_ attr:Array<Any>) {
        attribute = attr
        
        name = attr[indexSkillName] as? String
        photo = attr[indexSkillPhoto] as? String
        if let tmp_p = attr[indexSkillPower] as? Int { power = SkillPower(rawValue: tmp_p) ?? SkillPower.unKnown}
        if let tmp_s = attr[indexSkillMode] as? Int { state = SkillState(rawValue: tmp_s) ?? SkillState.unused}
        desc = attr[indexSkillDesc] as? String
    }
    convenience init() {
        self.init(MXSSkillCmd.shared.signetData[SkillBlankPhoto]!)
    }
    var concreteView: MXSSkillView? {
        didSet {
            concreteView?.belong = self
            concreteView?.powerPhoto = power
        }
    }
    var concreteBtn: MXSSkillBtn? {
        didSet {
            
        }
    }
    
    func disguisePoker(_ poker:MXSPoker) -> Bool {
        if self.power == .redToAttack {
            if poker.color == PokerColor.heart || poker.color == PokerColor.diamond {
                poker.actionGuise = .attack
                return true
            }
        }
        return false
    }
}

class MXSSkillCmd {

    //["name", "skill_000", 0, "desc"]
    var signetData: Dictionary<String,Array<Any>> = Dictionary<String,Array<Any>>()
    
    static let shared : MXSSkillCmd = {
        let single = MXSSkillCmd.init()
        let path = Bundle.main.path(forResource: "skill", ofType: "json")
        let url = URL(fileURLWithPath: path!)
        
        do {
            let data = try Data(contentsOf: url)
            let dict: Dictionary<String,Array<Any>> = try! JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! Dictionary<String,Array<Any>>
            single.signetData = dict
            
        } catch let error as Error? {
            print("读取本地数据出现错误!",error as Any)
        }
        
        return single
    }()
    
    //MARK:各种获得Skill方法
    func getSkillFromUUMark(_ uu: String) -> MXSSkill {
        if let attr = signetData[uu] {
            let skill = MXSSkill.init(attr)
            return skill
        }
        else { return getBlankSkill() }
    }
    
    func getPowerFromUUMark(_ uu: String) -> SkillPower {
        return getSkillFromUUMark(uu).power
    }
    
    func getBlankSkill() -> MXSSkill {
        return MXSSkill()
    }
    
    //MARK:array类型元数据
    func arrayModelData() -> Array<String> {
        var tmp = Array<String>()
        for (key, _) in signetData {
            tmp.append(key)
        }
        
        tmp.sort { (obj1, obj2) -> Bool in
            obj1 > obj2
        }
        return tmp
    }
}

