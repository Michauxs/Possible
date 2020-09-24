//
//  MXSHeroCmd.swift
//  Possible
//
//  Created by Sunfei on 2020/8/24.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit

class MXSHero {
    var isAxle: Bool = false
//    var isFighting: Bool = false
    var adjustGrasp: Bool = false
    
    var name: String = "HeroName"
    var photo: String = "hero_000"
    var graspCapacity: Int = 0
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
    var attribute: Array<Any>?
    var desc: String?
    
    var attackCount: Int = 0 {
        didSet {
            let arr = skillSet.filter { (item) -> Bool in item.power == SkillPower.WolfSt }
            if arr.count > 0 {
                attackCount = 0
            }
        }
    }
    var actionFromPoker: PokerAction?
    var discards:Array<MXSPoker>?
    func endActiveAndClearHistory () {
        stopAllSkill(.enable)
        aim = nil
        isActive = false
        isHoldOn = false
        actionFromPoker = nil
        discards = nil
        attackCount = 0
    }
    
    /**name photo hp skills desc*/
    init(_ attr:Array<Any>) {
        attribute = attr
        
        if let tmp_n = attr[indexHeroName] as? String { name = tmp_n }
        if let tmp_p = attr[indexHeroPhoto] as? String { photo = tmp_p }
        if let tmp_lp = attr[indexHeroHP] as? Int { LP = tmp_lp }
        
        if let uu_skills = attr[indexHeroSKFate] as? Array<String> {
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
        
        if attr.count > indexHeroDesc { desc = attr[indexHeroDesc] as? String }
    }
    
    var concreteView: MXSHeroView? {
        didSet {
            concreteView?.belong = self
            concreteView?.nameLabel?.text = name
            concreteView?.portraitImage?.image = UIImage.init(named: photo)
            concreteView?.LP = LP
            graspCapacity = LP
            concreteView?.skillsExp = self.skillExp
        }
    }
    /**被选择*/
    var isBeAimed: Bool = false {
        didSet {
            print("\(self.name) + isbeaimed \(isBeAimed)")
            concreteView?.isSelected = isBeAimed
        }
    }
    /**在等待对方*/
    var isHoldOn: Bool = false {
        didSet {
            concreteView?.isHoldOn = isHoldOn
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
    public func minsHP (_ hp:Int = 1) {
        self.HP = HP - hp
    }
    public func plusHP (_ hp:Int = 1) {
        self.HP = HP + hp
    }
    
    var isActive: Bool = false
    weak var aim: MXSHero? {
        willSet {
            aim?.isBeAimed = false
        }
        didSet {
            if aim != nil {
                aim?.isBeAimed = true
            }
        }
    }
    weak var aimedBy: MXSHero?
    
    //MARK:- other hero
    public func collectCard () {
        self.pokers.append(contentsOf: MXSPokerCmd.shared.push(collectNumb))
    }
    
    func canAttack() -> Bool {
        if self.pickes.count == 0  { return false }
        let poker_0 = self.pickes.first!
        let action = poker_0.actionGuise
        
        if self.aim == nil && action == PokerAction.recover && HP < LP { return true }
        if self.aim == nil  { return false }
        if action == PokerAction.unknown { return false }
        
        if action == PokerAction.attack {
            if attackCount == 0 {
                return true
            }
            return false
        }
        if action == PokerAction.warFire || action == PokerAction.arrowes || action == PokerAction.duel {
            return true
        }
        if (action == PokerAction.steal || action == PokerAction.destroy) && self.aim?.pokers.count != 0 {
            return true
        }
        if action == PokerAction.recover && aim!.HP < aim!.LP  {
            return true
        }
        
        return false
    }
    func canDefense() -> Bool {
        if self.pickes.count == 0 { return false }
        
        let action_pick = self.pickes.first!.actionGuise!
        let action_attck:PokerAction = self.aimedBy!.actionFromPoker!
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
     * true: other
     * false: oneself
     */
    func discard() -> Bool {
        let poker = self.pickes.first!
        if let aimed = self.aim {
            self.popCard(poker)
            if poker.actionGuise == PokerAction.duel {
                aimed.minsHP()
                return false
            }
            
            self.isActive = false
            
            aimed.aimedBy = self
            aimed.isActive = true
            return true
        }
        else { //oneself
            plusHP()
            return false
        }
    }
    
    /**AI方法。player不可调用*/
    func replyAttack() -> MXSPoker? {
        if isAxle { return nil }
        
        let action_attck = self.aimedBy?.actionFromPoker
        switch action_attck {
        case .attack:
            return minsHPOrDefenseWithAction(.defense)
        case .warFire:
            return minsHPOrDefenseWithAction(.attack)
        case .arrowes:
            return minsHPOrDefenseWithAction(.defense)
        case .destroy:
            return distributeWithState(.pass)
        case .steal:
            return distributeWithState(.transferring)
        default: break
        }
        
        return nil
    }
    func distributeWithState(_ state:PokerState) -> MXSPoker {
        if let poker = hasPokerWithAction(.detect) {
            popCard(poker)
            return poker
        } else {
            let index = Int(arc4random_uniform(UInt32(self.pokers.count)))
            let pok_random = self.pokers.remove(at: index)
            pok_random.state = state
            return pok_random
        }
    }
    func minsHPOrDefenseWithAction(_ action:PokerAction) -> MXSPoker? {
        if let poker = hasPokerWithAction(action) {
            popCard(poker)
            return poker
        }
        else {
            self.minsHP()
            return nil
        }
    }
    func hasPokerWithAction(_ action:PokerAction) -> MXSPoker? {
        if let index = self.pokers.firstIndex(where: { (item) -> Bool in item.actionGuise == action }) {
            return self.pokers[index]
        }
        else { return nil }
    }
    
    public func popCard(_ poker:MXSPoker) {
        self.pokers.removeAll(where: {$0 === poker})
        poker.state = .pass
        if poker.actionGuise == PokerAction.attack {
            attackCount += 1
        }
        
        self.actionFromPoker = poker.actionGuise
        self.discards = [poker]
    }
    
    public func freeAimAndBackActive() {
        self.isActive = false
        
        self.aimedBy?.aim = nil
        self.aimedBy?.isActive = true
        self.aimedBy = nil
    }
    /*--------------------------------------------*/
    public func hasPokerDoAttack() -> MXSPoker? {
        if aim == nil || self.pokers.count == 0 { return nil }
        
        for action in MXSPokerCmd.shared.priority {
            if let index = self.pokers.firstIndex(where: { (item) -> Bool in item.actionGuise == action }) {
                let poker = self.pokers[index]
                /**attack yet , check next action*/
                if (action == PokerAction.attack ) && self.attackCount != 0 { continue }
                /**aim no anyone poker , check next action*/
                if (action == PokerAction.steal || action == PokerAction.destroy) && aim!.pokers.count == 0 { continue }
                return poker
            }
        }
        return nil
    }
    /*--------------------------------------------*/
    
}

class MXSHeroCmd {
    
    var heroData: Array<Array<Any>> = Array<Array<Any>>()
    
    static let shared : MXSHeroCmd = {
        let single = MXSHeroCmd.init()
        let path = Bundle.main.path(forResource: "hero", ofType: "json")
        let url = URL(fileURLWithPath: path!)
        // 带throws的方法需要抛异常
        do {
            let data = try Data(contentsOf: url)
            let array: Array<Array<Any>> = try! JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! Array<Array<Any>>
//            for attr in array {
//                let hero = MXSHero.init(attr)
//                single.heroData.append(hero)
//            }
            single.heroData = array
        } catch let error as Error? {
            print("读取本地数据出现错误!",error as Any)
        }
        
        return single
    }()
    
    func random() -> MXSHero {
//        let rest = heroData.filter({$0.isFighting == false})
        let index = Int(arc4random_uniform(UInt32(heroData.count)))
        let attr = heroData[index]
        let hero = MXSHero.init(attr)
        return hero
    }
    
    func someoneFromName(_ uu:String) -> MXSHero? {
        if let index = heroData.firstIndex(where: { (hero) -> Bool in hero[indexHeroPhoto] as! String == uu }) {
            let attr = heroData[index]
            let hero = MXSHero.init(attr)
            return hero
        }
        return nil
    }
    
    func allHeroModel() -> Array<MXSHero> {
        var tmp = Array<MXSHero>()
        for attr in heroData {
            tmp.append(MXSHero.init(attr))
        }
        return tmp
    }
}
