//
//  MXSSkillBtn.swift
//  Possible
//
//  Created by Sunfei on 2020/9/14.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit

class MXSSkillBtn: UIButton {
    
    weak var belong:MXSSkill?
    var power: SkillPower?
    
//    convenience init(_ attr:Array<Any>) {
//        let name = attr[indexSkillName] as! String
//        self.init(name, fontSize: 315, textColor: .white)
//
//        self.belong?.attribute = attr
//        self.power = attr[indexSkillPower] as? SkillPower
//
//        setup()
//    }
    
    convenience init(skill:MXSSkill) {
        let name = skill.name
        self.init(name!, fontSize: 315, textColor: .white)
        self.belong = skill
        skill.concreteBtn = self
        self.power = skill.power
        
        setup()
    }
    
    func setup (){
        self.setTitleColor(.gray, for: .selected)
        self.setTitleColor(.black, for: .disabled)
        self.setRaius(1, borderColor: .white, borderWitdh: 1)
        
        self.status = self.belong!.state
                
    }
    
    var status: SkillState = .unused {
        didSet {
            if status == .keepOn {
                self.isEnabled = false
            }
            else if status == .enable {
                self.isSelected = true
            }
            else if status == .unable {
                self.isSelected = false
            }
            else { self.isEnabled = false }
        }
    }
    
}
