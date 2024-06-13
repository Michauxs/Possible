//
//  MXSHero.swift
//  Possible
//
//  Created by Sunfei on 2022/1/26.
//  Copyright © 2022 boyuan. All rights reserved.
//

import Foundation
import UIKit

enum HeroRoundCycle {
    case unknow
    case begin
    case getCrad
    case active
    case willEnd
    case end
}

enum HeroMonitorAction {
    case none
    case discard
    case freecard
    case random
    case randomResult
    case skill
}

class MXSHero {
    //monitor: discard  freecard  random  randomResult  skill
    
    // MARK: - property only note
    var isPlayer: Bool = false
    
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
    //var cycleState: CycleState = .blank
    
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
    
    var graspCount:Int = 0 {
        didSet {
            concreteView?.pokerCount = graspCount
        }
    }
    weak var GraspView: MXSGraspPokerView? {
        didSet {
            GraspView?.belong = self
        }
    }
    weak var leadingView: MXSLeadingView? {
        didSet {
            leadingView?.belong = self
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
    var ownPokers: [MXSPoker] = []
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
        
        MXSJudge.cmd.record(discardPokers: pokers, toAction: self.holdAction!)
        
        for poker in pokers {
            ownPokers.removeAll(where: { $0 === poker })
            poker.state = .pass
            MXSLog(poker, name+" lose poker = ")
        }
        
        self.graspCount = ownPokers.count
    }
    func getPokers(_ pokers:[MXSPoker]) {
        ownPokers.append(contentsOf: pokers)
        
        for poker in pokers {
            poker.state = .handOn
            MXSLog(poker, self.name + " get poker = ")
        }
        
    }
    
    //offensive/defensive
    /**只做 修正\前置判定\补充指定\记录 等前置操作 -> 反馈有无pokerView及其处置方式*/
    func discardPoker(reBlock:(_ needWaiting:Bool, _ type:PokerViewWay, _ pokeres:[MXSPoker]) -> Void) {
        
        let pickedPokers = self.picked
        let action = holdAction?.action
        self.losePokers(pickedPokers)
        //action修正
        //TODO: maybe ,can adjust that append Responder on picked poker
        if MXSJudge.cmd.responder.count == 0 && action == .remedy {
            MXSJudge.cmd.appendResponder(self)
        }
        MXSJudge.cmd.diary.append(holdAction!)
        
        //reply
        if holdAction?.fensive == .defensive {
            MXSLog(holdAction?.pokers as Any, "after ActivePicked be remove, the markAction'pokers")
            if holdAction?.action == .steal {
                reBlock(false, .comefrom, pickedPokers)
            }
            else {
                reBlock(false, .passed, pickedPokers)
            }
        }
        else {//active
            
            //note onestep active action
            lastActiveAction = holdAction
            MXSLog(picked, name + " Active with pokers")
            
            if holdAction?.aimType == .aoe {
                MXSJudge.cmd.selectAllPlayer()
                reBlock(true, .passed, pickedPokers)
            }
            else if holdAction?.aimType == .all {
                
            }
            else if holdAction?.aimType == .ptp {
                if action == .give {
                    reBlock(true, .awayfrom, pickedPokers)
                }
                else {
                    if action == .attack {
                        attackCount+=1
                    }
                    reBlock(true, .passed, pickedPokers)
                }
            }
            else if holdAction?.aimType == .oneself {
                reBlock(false, .passed, pickedPokers)
            }
            else {
                
            }
        }
        
        func discardPokerOnDefensive() {
            
        }
        
        /*------------------------------*/
        self.picked.removeAll()// giveup
    }
    
    func rollRandomPoker() -> MXSPoker {
        let index = Int(arc4random_uniform(UInt32(ownPokers.count)))
        MXSLog("\(ownPokers.count)" + "  =>  random idx:" + "\(index)", "Poker count")
        return ownPokers.remove(at: index)
    }
    
    func endActiveByClearStatus () {
        stopAllSkill(.enable)
        signStatus = .blank
        lastActiveAction = nil
        attackCount = 0
    }
    
    // MARK: - hero action
    weak var aim:MXSHero?
    weak var aimedBySomeone:MXSHero?
    var lastActiveAction:MXSOneAction?
    var holdAction:MXSOneAction?
    
    func endCurrentCycle( next:((_ hero:MXSHero)->Void)?) {
        MXSJudge.cmd.dealcardForNextLeader { hero, pokers in
            if next != nil { next!(hero) }
        }
    }
    /**(common: ParryResultType, one: ParryResultCallback, two: @escaping HeroParryResult) {
     func cb() {
         two(.receive, nil, nil)
     }
     one(.answered, nil, nil, cb)
 }*/
    //(_ parry:ParryResultType, _ pokers:[MXSPoker]?, _ pokerWay:LosePokerWay?)
    public func parryAttack(parryResult: ParryResultCallback, next: @escaping CallbackBlock) {
        let leader = MXSJudge.cmd.leader!
        let pokers: [MXSPoker] = leader.holdAction!.pokers
        
        let action_leader = leader.holdAction!.action
        let action_reply: PokerAction = leader.holdAction!.reply.act
        
        MXSJudge.cmd.diary.append(self.holdAction!)
        
        /**在调用方法中callback**/
        func callback() {
            next()
        }
        
        if action_reply == .recover {
            parryResult(.recover, nil, nil, callback)
        }
        else if action_reply == .gain {
            parryResult(.receive, pokers, .comefrom, callback)
        }
        else {
            if self.isPlayer {
                //replyer is axle: operate
                parryResult(.operate, nil, nil, callback)
            }
            else {
                if let index = self.ownPokers.firstIndex(where: { poker in poker.actionGuise == action_reply }) {
                    let contain = self.ownPokers[index]
                    parryResult(.answered, [contain], .passed, callback)
                    
                    if leader.holdAction?.aimType == .aoe { MXSLog(self.name + "responder -->  reply group") }
                }
                else {
                    if action_leader == .steal {
                        let random = self.rollRandomPoker()
                        MXSLog(random, "The poker will awayfrom ")
                        parryResult(.mismatch, [random], .awayfrom, callback)
                    }
                    else if action_reply == .destroy {
                        let random = self.rollRandomPoker()
                        parryResult(.beDestroyed, [random], .passed, callback)
                    }
                    else if action_reply == .attack || action_reply == .arrowes || action_reply == .warFire {
                        parryResult(.injured, nil, nil, callback)
                    }
                    
                    if leader.holdAction?.aimType == .aoe { MXSLog(self.name + "responder --> can't reply group") }
                }
            }
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
    func joingame() {
        MXSJudge.cmd.subject.append(self)
    }
    
    func distakeAllAim() {
        holdAction?.aim.removeAll()
    }
    
    
    //MARK: -- Test
    func delayedFunc(dely: DelayedBlock) -> MXSHero {
        MXSLog("delayedFunc block")
        dely(.answered)
        return self
    }
    func directFunc() {
        MXSLog("directFunc")
    }
    
    
    func delayedFuncReturnBlock(_ sign: ParryResultType) -> DelayedBlockReturn {
        MXSLog(sign, "delayedFuncReturnBlock block")
        return { (sign: ParryResultType) in
            return self
        }


    }
    
    
    //(_ parry:ParryResultType, _ pokers:[MXSPoker]?, _ pokerWay:PokerViewWay?, callback: CallbackBlock)
    func twoBlockMethod(common: ParryResultType, one: ParryResultCallback, two: @escaping HeroParryResult) {
        func cb() {
            two(.receive, nil, nil)
        }
        one(.answered, nil, nil, cb)
    }
    
    /**
     
     func makeIncrementer(amount: Int) -> ((Int) -> Int) {
         return { (value: Int) in
             return value + amount
         }
     }
      
     let incrementByTen = makeIncrementer(amount: 10)
     let newValue = incrementByTen(5) // 返回 15
     
     */
}
