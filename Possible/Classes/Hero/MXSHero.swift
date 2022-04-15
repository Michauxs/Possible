//
//  MXSHero.swift
//  Possible
//
//  Created by Sunfei on 2022/1/26.
//  Copyright © 2022 boyuan. All rights reserved.
//

import Foundation
import UIKit

class MXSHero {
    
    // MARK: - property only note
    var isAxle: Bool = false
    var adjustGrasp: Bool = false
    
    var name: String = "HeroName"
    var photo: String = "hero_000"
    
    var collectNumb: Int = 2
    var attribute: Dictionary<String,Any> = [:]
    var desc: String?
    
    var skillFate: Array<MXSSkill> = Array<MXSSkill>()
    var skillExp: Array<MXSSkill> = Array<MXSSkill>() {
        didSet {
            //可以在这里做本地存储
        }
    }
    var skillSet: Array<MXSSkill> = Array<MXSSkill>()
    
    
    var attackLimit: Int = 1
    var attackCount: Int = 0
    
    var signStatus:HeroSignStatus = .blank {
        didSet {
            concreteView?.signStatus = signStatus
        }
    }
    
    // MARK: - property-method
    
    /**总量*/
    var HPSum: Int = 4
    /**当前量*/
    var HPCurrent: Int = 4 {
        didSet {
            concreteView?.HPCurrent = HPCurrent
            if HPCurrent == 0 {
                self.concreteView?.controller?.someHeroHPZero(self)
            }
        }
    }
    public func minsHP (_ hp:Int = 1) {
        self.HPCurrent = HPCurrent - hp
    }
    public func plusHP (_ hp:Int = 1) {
        self.HPCurrent = HPCurrent + hp
    }
    
    
    // MARK: - method
    init(_ attr:Dictionary<String,Any>) { /**name photo hp skills desc*/
        attribute = attr
        
        if let tmp_n = attr[kStringName] as? String { name = tmp_n }
        if let tmp_p = attr[kStringImage] as? String { photo = tmp_p }
        if let tmp_lp = attr[kStringHP] as? Int { HPSum = tmp_lp }
        
        if let uu_skills = attr[kStringSKFate] as? Array<String> {
            for uu in uu_skills {
                let skill = MXSSkillCmd.shared.getSkillFromUUMark(uu)
                skillFate.append(skill)
            }
            skillSet.append(contentsOf: skillFate)
        }
        if let uu_skills = UserDefaults.standard.array(forKey: photo) {
            for uu in uu_skills {
                let skill = MXSSkillCmd.shared.getSkillFromUUMark(uu as! String)
                skillExp.append(skill)
            }
            skillSet.append(contentsOf: skillExp)
        }
        
        desc = attr[kStringDesc] as? String
    }
    
    var concreteView: MXSHeroView? {
        didSet {
            concreteView?.belong = self
            concreteView?.nameLabel.text = name
            concreteView?.portraitImage.image = UIImage.init(named: photo)
            concreteView?.HPSum = HPSum
            concreteView?.skillsExp = self.skillExp
        }
    }
    
    
    //MARK: - skill
    func stopAllSkill(_ state:SkillState) {
        for skill in skillSet.filter({$0.state == state}) {
            skill.state = .unable
        }
    }
    func startingSkill(_ skill:MXSSkill) {
        skill.state = .enable
        if let poker = pickes.first {
            let _ = skill.disguisePoker(poker)
        }
    }
    func stopSkill(_ skill:MXSSkill) {
        skill.state = .unable
        for poker in self.pickes {
            poker.actionGuise = poker.actionFate
            poker.colorGuise = poker.color
        }
    }
    
    func exchangeSkillExp(marks:Array<String>) {
        var tmp = Array<MXSSkill>()
        for uu in marks {
            let skill = MXSSkillCmd.shared.getSkillFromUUMark(uu)
            tmp.append(skill)
        }
        self.skillExp = tmp
        
        skillSet.removeAll()
        skillSet.append(contentsOf: skillFate)
        skillSet.append(contentsOf: skillExp)
    }
    
    //MARK:- pokers
    var pokers: Array<MXSPoker> = []
    lazy var pickes: Array<MXSPoker> = {
        return Array<MXSPoker>.init()
    }()
    func pickPoker(_ poker:MXSPoker) {
        pickes.append(poker)
        self.transTheAction()
    }
    func freePoker(_ poker:MXSPoker) {
        pickes.removeAll(where: {$0 === poker})
        self.transTheAction()
    }
    func transTheAction() {
        if pickes.count > 0 {
            let pok = pickes.first!
            currentAction?.action = pok.actionGuise
        }
        else {
            currentAction?.reset()
        }
    }
    
    func endActiveAndClearHistory () {
        stopAllSkill(.enable)
        signStatus = .blank
        lastStep = nil
        attackCount = 0
    }
    
    // MARK: - hero action
    var lastStep:MXSOneAction?
    var currentAction:MXSOneAction?
    public func disPokerCurrentPickes() {
        
    }
    
    //MARK:- other hero
    public func collectCard () {
        self.pokers.append(contentsOf: MXSPokerCmd.shared.push(collectNumb))
    }
    
    /**return - need cycle
     * true: 1 vs 1
     * false: 1 vs 0 / 1 vs N
     */
    func discard() -> Bool {
        let poker = self.pickes.first!
        
        if let aimed = MXSJudge.cmd.passive.first {
            self.popCard(poker)
            if poker.actionGuise == PokerAction.duel {
                aimed.minsHP()
                MXSJudge.cmd.appendOrRemovePassive(aimed)
                return false
            }
            
            self.signStatus = .blank
            return true
        }
        else { // oneself \ group
            return false
        }
    }
    
    /*--------------------------------------------*/
    
    func joingame(){
        MXSJudge.cmd.subject.append(self)
    }
}
