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
    
    var name: String = "HeroName"
    var photo: String = "hero_000"
    var attribute: Dictionary<String,Any> = [:]
    var desc: String?
    
    var collectNumb: Int = 2
    var attackLimit: Int = 1
    var attackCount: Int = 0
    var attackPower: Int = 1
    
    var skillFate: Array<MXSSkill> = Array<MXSSkill>()
    var skillExp: Array<MXSSkill> = Array<MXSSkill>() {
        didSet {
            //可以在这里做本地存储
        }
    }
    var skillSet: Array<MXSSkill> = Array<MXSSkill>()
    var cycleState: CycleState = .blank
    
    // MARK: - property-method
    var HPSum: Int = 4 {
        didSet {
            self.HPCurrent = HPSum
        }
    }
    var HPCurrent: Int = 4 {
        didSet {
            concreteView?.HPCurrent = HPCurrent
            MXSLog(HPCurrent, self.name + "'hp ")
        }
    }
    func canRecover() -> Bool {
        return HPCurrent < HPSum
    }
    public func minsHP (_ hp:Int = 1) {
        concreteView?.dangrousFade()
        self.HPCurrent = HPCurrent - hp
    }
    public func plusHP (_ hp:Int = 1) -> Bool {
        if  self.HPCurrent >= self.HPSum { return false }
        
        var willHP = HPCurrent + hp
        if  willHP > self.HPSum { willHP = self.HPSum }
        self.HPCurrent = willHP
        return true
    }
    
    var signStatus:HeroSignStatus = .blank {
        didSet {
            concreteView?.signStatus = signStatus
        }
    }
    
    
    // MARK: - View
    init(_ attr:[String:Any]) { /**name photo hp skills desc*/
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
    
    var pokersView: MXSGraspPokerView? {
        didSet {
            pokersView?.belong = self
        }
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
    
    
    //MARK: - Pokers
    var holdPokers: [MXSPoker] = []
    lazy var picked: [MXSPoker] = []
    func pickPoker(_ poker:MXSPoker) {
        picked.append(poker)
        self.transTheAction()
    }
    func freePoker(_ poker:MXSPoker) {
        picked.removeAll(where: { $0 === poker })
        self.transTheAction()
    }
    func transTheAction() {
        if picked.count > 0 {
            let pok = picked.first!
            holdAction?.action = pok.actionGuise
        }
        else {
            holdAction?.reset()
        }
    }
    func losePokers(_ pokers:[MXSPoker]) {
        for poker in pokers {
            holdPokers.removeAll(where: { $0 === poker })
            poker.state = .pass
            MXSLog(poker, name+" -lose poker")
        }
        pokersView?.layoutPokerView()
        concreteView?.pokerCount = holdPokers.count
    }
    func getPokers(_ pokers:[MXSPoker]) {
        holdPokers.append(contentsOf: pokers)
        for poker in pokers {
            poker.state = .handOn
            MXSLog(poker, name+" +get poker")
        }
        pokersView?.layoutPokerView()
        concreteView?.pokerCount = holdPokers.count
    }
    /**return is need reply*/
    func discardPoker(reBlock:(_ type:DiscardPokerType, _ poker:[MXSPoker]) -> Void) -> Bool {
        
        losePokers(self.picked)
        MXSJudge.cmd.diary.append(holdAction!)
        
        if holdAction?.action == .give {
            reBlock(.handover, picked)
        }
        else {
            reBlock(.passed, picked)
        }
        
        var need_wait_reply = true
        if holdAction?.type == .active {
            
            MXSJudge.cmd.markDiscardedOnAction()
            //note onestep active action
            lastActiveAction = holdAction
            
            let action = holdAction?.action
            if action == .attack {
                attackCount+=1
            }
            else if action == .remedy {
                let _ = plusHP()
                need_wait_reply = false
            }
            
            MXSLog(picked, name+" Active with pokers")
        }
        else {//.reply
            MXSLog(picked, name+" Reply with pokers")
        }
        
        self.picked.removeAll()// giveup
        if holdAction?.type == .active { MXSLog(holdAction?.pokers as Any, "after ActivePicked be remove, the markAction'pokers") }
        
        return need_wait_reply
    }
    
    func rollRandomPoker() -> MXSPoker {
        let index = Int(arc4random_uniform(UInt32(holdPokers.count)))
        MXSLog("\(holdPokers.count)" + "  =>  random idx:" + "\(index)", "Poker count")
        return holdPokers.remove(at: index)
    }
    
    func endActiveByClearStatus () {
        stopAllSkill(.enable)
        signStatus = .blank
        lastActiveAction = nil
        attackCount = 0
    }
    
    // MARK: - hero action
    var lastActiveAction:MXSOneAction?
    var holdAction:MXSOneAction?
    func makeOneReplyAction() {
        holdAction = MXSOneAction(axle: self, type: .reply)
    }
    
    //MARK: - skill
    func stopAllSkill(_ state:SkillState) {
        for skill in skillSet.filter({$0.state == state}) {
            skill.state = .unable
        }
    }
    func startingSkill(_ skill:MXSSkill) {
        skill.state = .enable
        if let poker = picked.first {
            let _ = skill.disguisePoker(poker)
        }
    }
    func stopSkill(_ skill:MXSSkill) {
        skill.state = .unable
        for poker in self.picked {
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
    
    /*--------------------------------------------*/
    //MARK: - hero->Judge
    func joingame(){
        MXSJudge.cmd.subject.append(self)
    }
    func takeOrDisAimAtHero(_ hero:MXSHero) {
        if let idx = holdAction?.aim.firstIndex(where: { hero_one in
            hero_one === hero
        }) {
            holdAction?.aim.remove(at: idx)
        }
        else {
            holdAction?.aim.append(hero)
        }
        MXSJudge.cmd.appendOrRemoveResponder(hero)
    }
    
    func distakeAllAim() {
        holdAction?.aim.removeAll()
    }
}
