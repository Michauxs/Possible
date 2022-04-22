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
            self.concreteBtn?.status = state
        }
    }
    var quality: Int?
    var desc: String?
    var photo: String?
    
    var attribute:[String : Any] = MXSSkillCmd.shared.skillData[SkillBlankPhoto]!
    
    func resetAttr() {
        attribute = MXSSkillCmd.shared.skillData[SkillBlankPhoto]!
    }
    
    //["name", "skill_000", 0, "desc"]
    init(_ attr:[String : Any]) {
        attribute = attr
        
        name = attr[kStringName] as? String
        photo = attr[kStringImage] as? String
        if let tmp_p = attr[kStringSkillPower] as? Int { power = SkillPower(rawValue: tmp_p) ?? SkillPower.unKnown}
        if let tmp_s = attr[kStringSkillMode] as? Int { state = SkillState(rawValue: tmp_s) ?? SkillState.unused}
        desc = attr[kStringDesc] as? String
    }
    
    convenience init() {
        self.init(MXSSkillCmd.shared.skillData[SkillBlankPhoto]!)
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
    var skillData: [String : [String : Any]] = [:]
    
    static let shared : MXSSkillCmd = {
        let single = MXSSkillCmd.init()
        let path = Bundle.main.path(forResource: "skill", ofType: "json")
        let url = URL(fileURLWithPath: path!)
        
        do {
            let data = try Data(contentsOf: url)
            let dict: [String : [String : Any]] = try! JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String : [String : Any]]
            single.skillData = dict
            
        } catch let error as Error? {
            MXSLog(error as Any, "读取本地数据出现错误!")
        }
        
        return single
    }()
    
    //MARK:各种获得Skill方法
    func getSkillFromUUMark(_ uu: String) -> MXSSkill {
        if let attr : [String : Any] = skillData[uu] {
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
        for (key, _) in skillData {
            tmp.append(key)
        }
        
        tmp.sort { (obj1, obj2) -> Bool in
            obj1 > obj2
        }
        return tmp
    }
}

