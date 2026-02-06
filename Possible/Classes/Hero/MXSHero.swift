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

enum GetPokerType {
    case freecard
    case wrest
    case salvage
}


class MXSHero {
    //monitor: discard  freecard  random  randomResult  skill
    
    // MARK: - property only note
    var isPlayer: Bool = false
    
    var name: String = "HeroName"
    var photo: String = "hero_000"
    var seq: Int = 0
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
    public func HPDecrease (_ hp:Int = 1) {
        concreteView?.dangrousFade()
        self.HPCurrent = HPCurrent - hp
    }
    public func HPIncrease (_ hp:Int = 1) -> Bool {
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
    var ownPokers = [MXSPoker]()
    lazy var picked: [MXSPoker] = []
    func pickPoker(_ poker:MXSPoker) {
        picked.append(poker)
        self.transTheAction()
    }
    func pickPokers(_ pokers:[MXSPoker]) {
        for poker in pokers {
            picked.append(poker)
        }
        self.transTheAction()
    }
    func freePoker(_ poker:MXSPoker) {
        picked.removeAll(where: { $0 === poker })
        self.transTheAction()
    }
    func transTheAction() {
        if picked.count > 0 {
            let pok = picked.first!
            holdAction?.aFunc = pok.funcGuise
            holdAction?.aimType = .oneself
        }
        else {
            holdAction?.reset()
        }
    }
    func losePokers(_ pokers:[MXSPoker]) {
        MXSJudge.cmd.record(pokers: pokers, toAction: self.holdAction!)
        
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
    
    func holdHisPokersView(_ pokers:[MXSPoker], complete:@escaping ()->Void) {
        self.GraspView?.holdPokerView(pokers, complete: nil)
        /**不一定有grasp，一定有表像， complete在表像动画后 返回**/
        self.concreteView?.getPokerAnimate(pokers, complete: {
            complete()
        })
    }
    
    
    //offensive/defensive
    /**只做 修正\前置判定\补充指定\记录 等前置操作 -> 反馈有无pokerView及其处置方式*/
    func discardPoker(reBlock:(_ target:[MXSHero], _ pokerWay:PokerViewWay, _ pokers:[MXSPoker]) -> Void) {
        
        let pokers = self.picked
        let act = holdAction!.aFunc
        self.losePokers(pokers)
        
        MXSJudge.cmd.correctHoldAction(action: holdAction!)
        
        if holdAction!.fensive == .defensive {//被动
            MXSLog(holdAction?.pokers as Any, "after ActivePicked be remove, the markAction'pokers")
            
            if act == .give {
                reBlock([MXSJudge.cmd.leader!], .awayfrom, pokers)
            }
            else {
                reBlock([], .passed, pokers)
            }
        }
        else {
            MXSLog(picked, name + " Active with pokers: ")
            
            //note onestep active action
            lastActiveAction = holdAction
            
            if holdAction!.aim.count > 0 {
                if act == .give {
                    reBlock(MXSJudge.cmd.responder, .awayfrom, pokers)
                    return
                }
                else { //.duel .steal .destroy  .attack
                    if act == .attack {
                        attackCount+=1
                    }
                }
            }
            
            //默认passed，其他way，要提前return
            reBlock(MXSJudge.cmd.responder, .passed, pokers)
        }
        
        /*------------------------------*/
        self.picked.removeAll() // giveup
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
    
    
    
    //(_ parry:ParryResultType, _ pokers:[MXSPoker]?, _ pokerWay:LosePokerWay?)
    public func replyAction(replyResult: ReplyResultCallback, next: @escaping CallbackBlock) {
        let leader = MXSJudge.cmd.leader!
        let pokers: [MXSPoker] = leader.holdAction!.pokers
        
        let action_leader = leader.holdAction!.aFunc
        let action_reply: PokerFunc = leader.holdAction!.reply.act
        
        MXSJudge.cmd.diary.append(self.holdAction!)
        
        /**在调用方法中callback**/
        func callback() {
            next()
        }
        
        if action_reply == .recover {
            replyResult(.recover, nil, nil, callback)
        }
        else if action_reply == .gain {
            replyResult(.receive, pokers, .comefrom, callback)
        }
        else {
            if self.isPlayer {
                //replyer is axle: operate
                replyResult(.operate, nil, nil, callback)
            }
            else {
                if let index = self.ownPokers.firstIndex(where: { poker in poker.funcGuise == action_reply }) {
                    let contain = self.ownPokers[index]
                    replyResult(.answered, [contain], .passed, callback)
                    
                    if leader.holdAction?.aimType == .aoe { MXSLog(self.name + "responder -->  reply group") }
                }
                else {
                    if action_leader == .steal {
                        let random = self.rollRandomPoker()
                        MXSLog(random, "The poker will awayfrom ")
                        replyResult(.beStolen, [random], .awayfrom, callback)
                    }
                    else if action_leader == .destroy {
                        let random = self.rollRandomPoker()
                        replyResult(.beDestroyed, [random], .passed, callback)
                    }
                    else if action_leader == .attack || action_leader == .duel || action_leader == .arrowes || action_leader == .warFire {
                        replyResult(.injured, nil, nil, callback)
                    }
                    
                    if leader.holdAction?.aimType == .aoe { MXSLog(self.name + " responder --> can't reply group") }
                }
            }
            
        }//
    }
    
    func sufferConsequence(reBlock:ReplyResultCallback, next: @escaping CallbackBlock) {
        //let conseq = leader?.holdAction?.consequence
        let hero:MXSHero = MXSJudge.cmd.responder.first!
        
        /**在调用方法中callback**/
        func callback() {
            next()
        }
        
//        let action_reply = MXSJudge.cmd.leader!.holdAction!.reply.act
        let action = MXSJudge.cmd.leader?.holdAction?.aFunc
        switch action {
        case .unknown, .dodge, .detect, .recover, .gain, .remedy, .give:
            break
            
        /**无此操作**/
//        case .give:
//            let pokers = MXSJudge.cmd.leader?.lastActiveAction?.pokers
//            MXSLog(pokers, "The poker will comefrom ")
//            reBlock(.receive, pokers, .handle, callback)
            
        case .attack, .warFire, .arrowes, .duel:
            reBlock(.injured, nil, nil, callback)
            
        case .steal:
            let random = hero.rollRandomPoker()
            MXSLog(random, "The poker will awayfrom ")
            reBlock(.beStolen, [random], .awayfrom, callback)
            
        case .destroy:
            let random = hero.rollRandomPoker()
            reBlock(.beDestroyed, [random], .passed, callback)
            
        case .none:
            break
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
            poker.funcGuise = poker.funcFate
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
    func twoBlockMethod(common: ParryResultType, one: ReplyResultCallback, two: @escaping HeroParryResult) {
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
