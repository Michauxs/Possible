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
    
    
    //MARK:- sign status
    var signStatus:HeroSignStatus = .blank {
        didSet {
            concreteView?.signStatus = signStatus
        }
    }
    var isCollectedCard:Bool = false
    
    //MARK:- hero action
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
            return false
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
    
    /**AI方法。player不可调用*/
    func replyAttack() -> MXSPoker? {
        if isAxle { return nil }
        
        let action_attck = MXSJudge.cmd.leaderActiveAction
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
    }
    
    /*--------------------------------------------*/
    public func hasPokerDoAttack() -> MXSPoker? {
        if MXSJudge.cmd.passive.count == 0 || self.pokers.count == 0 { return nil }
        
        for action in MXSPokerCmd.shared.priority {
            if let index = self.pokers.firstIndex(where: { (item) -> Bool in item.actionGuise == action }) {
                let poker = self.pokers[index]
                /**attack yet , check next action*/
                if (action == PokerAction.attack ) && self.attackCount != 0 { continue }
                /**aim no anyone poker , check next action*/
                if (action == PokerAction.steal || action == PokerAction.destroy) && MXSJudge.cmd.passive.first!.pokers.count == 0 { continue }
                return poker
            }
        }
        return nil
    }
    /*--------------------------------------------*/
    
    func joingame(){
        MXSJudge.cmd.subject.append(self)
    }
}

class MXSHeroCmd {
    
    var heroData: Array<Dictionary<String,Any>> = []
    
    lazy var allHeroModel : [MXSHero] = {
        var all : [MXSHero] = [MXSHero]()
        for attr in heroData {
            all.append(MXSHero.init(attr))
        }
        return all
    }()
    
    lazy var unknownHero: MXSHero = MXSHero.init(["name": "Unknown", "image": "hero_000", "hp": 4, "skill": ["skill_010"], "desc": "unknown" ])
    
    static let shared : MXSHeroCmd = {
        let single = MXSHeroCmd.init()
        let path = Bundle.main.path(forResource: "hero", ofType: "json")
        let url = URL(fileURLWithPath: path!)
        // 带throws的方法需要抛异常
        do {
            let data = try Data(contentsOf: url)
            let array: [[String : Any]] = try! JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [[String : Any]]
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
        if let index = heroData.firstIndex(where: { (hero) -> Bool in hero[kStringImage] as! String == uu }) {
            let attr = heroData[index]
            let hero = MXSHero.init(attr)
            return hero
        }
        return nil
    }
    
    func getNewBlankHero() ->MXSHero {
        return MXSHero.init(["name": "Unknown", "image": "hero_000", "hp": 4, "skill": ["skill_010"], "desc": "unknown" ])
    }
}
