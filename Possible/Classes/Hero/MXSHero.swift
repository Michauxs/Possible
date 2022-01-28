//
//  MXSHero.swift
//  Possible
//
//  Created by Sunfei on 2022/1/26.
//  Copyright © 2022 boyuan. All rights reserved.
//

import Foundation

class MXSHero {
    var isAxle: Bool = false
    var adjustGrasp: Bool = false
    
    var name: String = "HeroName"
    var photo: String = "hero_000"
    var graspCapacity: Int = 0
    
    /**name photo hp skills desc*/
    init(_ attr:Dictionary<String,Any>) {
        attribute = attr
        
        if let tmp_n = attr[kStringName] as? String { name = tmp_n }
        if let tmp_p = attr[kStringImage] as? String { photo = tmp_p }
        if let tmp_lp = attr[kStringHP] as? Int { LP = tmp_lp }
        
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
            concreteView?.LP = LP
            graspCapacity = LP
            concreteView?.skillsExp = self.skillExp
        }
    }
    
    
    //MARK:- hero property
    /**总量*/
    var LP: Int = 4
    /**当前量*/
    var HP: Int = 4 {
        didSet {
            concreteView?.hp = HP
            graspCapacity = HP
            if HP == 0 {
                self.concreteView?.controller?.someHeroHPZero(self)
            }
        }
    }
    public func minsHP (_ hp:Int = 1) {
        self.HP = HP - hp
    }
    public func plusHP (_ hp:Int = 1) {
        self.HP = HP + hp
    }
    
    //MARK:- skill
    var skillFate: Array<MXSSkill> = Array<MXSSkill>()
    var skillExp: Array<MXSSkill> = Array<MXSSkill>() {
        didSet {
            //可以在这里做本地存储
        }
    }
    var skillSet: Array<MXSSkill> = Array<MXSSkill>()
    
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
        for skill in skillSet.filter({$0.state == .enable || $0.state == .keepOn}) {
            let _ = skill.disguisePoker(poker)
        }
        
    }
    func disPickPoker(_ poker:MXSPoker) {
        poker.actionGuise = poker.actionFate
        poker.colorGuise = poker.color
        pickes.removeAll(where: {$0 === poker})
    }
    
    var collectNumb: Int = 2
    var attribute: Dictionary<String,Any> = [:]
    var desc: String?
    
    var attackCount: Int = 0 {
        didSet {
            let arr = skillSet.filter { (item) -> Bool in item.power == SkillPower.WolfSt }
            if arr.count > 0 {
                attackCount = 0
            }
        }
    }
    var lastStep:MXSOneAction?
    func endActiveAndClearHistory () {
        stopAllSkill(.enable)
        signStatus = .blank
        lastStep = nil
        attackCount = 0
    }
    
    
    // MARK: - sign status
    var signStatus:HeroSignStatus = .blank {
        didSet {
            concreteView?.signStatus = signStatus
        }
    }
    
    // MARK: - hero action
    public func disPokerCurrentPickes() {
        
    }
    
    //MARK:- other hero
    public func collectCard () {
        self.pokers.append(contentsOf: MXSPokerCmd.shared.push(collectNumb))
    }
    
    func canAttack() -> Bool {
        if self.pickes.count == 0  { return false }
        
        let poker_0 = self.pickes.first!
        let action:PokerAction? = poker_0.actionGuise
        if action == .unknown { return false }
        
        let passive = MXSJudge.cmd.passive
        if passive.count == 0 {//自主牌/群
            if action == .recover && HP < LP { return true }
            if (action == .warFire || action == .arrowes) { return true }
        }
        else {
            if action == .attack {
                return attackCount == 0
            }
            if action == .duel {
                return true
            }
            if (action == .steal || action == .destroy) && passive.first!.pokers.count != 0 {
                return true
            }
            if action == .recover && passive.first!.HP < passive.first!.LP  {
                return true
            }
        }
        
        return false
    }
        
    func canDefense() -> Bool {
        if self.pickes.count == 0 { return false }
        
        let action_pick = self.pickes.first!.actionGuise
        let action_attck:PokerAction = MXSJudge.cmd.leaderActiveAction!
        var action_reply: PokerAction?
        if action_attck == .attack || action_attck == .arrowes {
            action_reply = .defense
        }
        else if action_attck == .steal || action_attck == .destroy {
            action_reply = .detect
        }
        else if action_attck == .warFire {
            action_reply = .attack
        }
        else {
            action_reply = .unknown
        }
        
        return action_reply == action_pick
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
