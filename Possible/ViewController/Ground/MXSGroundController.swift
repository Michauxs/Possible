//
//  MXSGroundController.swift
//  HaiOn
//
//  Created by Sunfei on 2020/8/12.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit


class MXSGroundController: MXSViewController {
    
    
    let pickHeroView = MXSPickHeroView.init(frame: CGRect.init(x: 0, y: 0, width: MXSSize.Sw, height: MXSSize.Sh))
    
    /* -------- user enterface view -------- */
    let passedView: MXSPassedView = MXSPassedView.init()
    let leadingView: MXSLeadingView = MXSLeadingView.init()
    
    var player: MXSHero = MXSHeroCmd.shared.getNewBlankHero()
    let playerView = MXSHeroView.init(seqNo: 1)
    let graspPokerView: MXSGraspPokerView = MXSGraspPokerView.init(frame: CGRect.zero)
    let skillDivView: UIScrollView = UIScrollView.init()
    /* --------                    -------- */
    
    var heroConcreteView:[MXSHeroView] = [MXSHeroView]()
    
    var numberOfChair: Int = 0 {
        didSet {
            for index in 2...numberOfChair {
                let oppontView = MXSHeroView.init(seqNo: index)
                //view.addSubview(oppontView)
                oppontView.controller = self
                
                self.heroConcreteView.append(oppontView)
            }
            
            var frameArray:[CGRect] = [CGRect]()
            let top_width = MXSSize.Sw - MXSSize.Hw*2
            
            if numberOfChair == 2 {
                frameArray = [CGRect(x: (MXSSize.Hw + top_width - MXSSize.Hw)*0.5, y: 0, width: MXSSize.Hw, height: MXSSize.Hh)]
                
            }
            else if numberOfChair == 3 {
                frameArray = [CGRect(x: MXSSize.Hw + top_width*0.66 - MXSSize.Hw*0.5, y: 0, width: MXSSize.Hw, height: MXSSize.Hh),
                              CGRect(x: MXSSize.Hw + top_width*0.33 - MXSSize.Hw*0.5, y: 0, width: MXSSize.Hw, height: MXSSize.Hh)]
            }
            else if numberOfChair == 4 {
                frameArray = [CGRect(x: MXSSize.Hw + top_width*0.75 - MXSSize.Hw*0.5, y: 0, width: MXSSize.Hw, height: MXSSize.Hh),
                              CGRect(x: MXSSize.Hw + top_width*0.5 - MXSSize.Hw*0.5, y: 0, width: MXSSize.Hw, height: MXSSize.Hh),
                              CGRect(x: MXSSize.Hw + top_width*0.25 - MXSSize.Hw*0.5, y: 0, width: MXSSize.Hw, height: MXSSize.Hh)]
            }
            else if numberOfChair > 4 {
                frameArray.append(CGRect(x: MXSSize.Sw - MXSSize.Hw, y:(MXSSize.Sh - MXSSize.Hh)*0.5 , width: MXSSize.Hw, height: MXSSize.Hh))
                let top_numb:CGFloat = CGFloat(numberOfChair-3)
                let div_width = top_width / top_numb
                for index in 0..<numberOfChair-3 {
                    frameArray.append(CGRect(x: MXSSize.Hw + top_width - div_width*CGFloat(index+1) + (div_width-MXSSize.Hw)*0.5, y:0 , width: MXSSize.Hw, height: MXSSize.Hh))
                }
                
                frameArray.append(CGRect(x: 0, y:(MXSSize.Sh - MXSSize.Hh)*0.5 , width: MXSSize.Hw, height: MXSSize.Hh))
            }
            else {
                //frameArray = []
            }
            
            for index in 0..<frameArray.count {
                let someoneView = self.heroConcreteView[index+1]
                view.addSubview(someoneView)
                someoneView.frame = frameArray[index]
            }
        }
    }
    
    //MARK:- viewdidload
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MXSNetServ.shared.belong = self
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        /** self.backgroundColor = UIColor(patternImage: UIImage(named:"recentExam_bgimg")!) //平铺  */
        /*self.view.layer.contents = UIImage.init(named: "play_bg")?.cgImage  // 拉伸*/
        
        MXSJudge.cmd.desktop = self;
        MXSPokerCmd.shared.ready()
        
        self.initionalSubViewes()
        /*--------------------------------------------*/
        self.readyModelForView()
    }
        
    func initionalSubViewes() {
        let pveBtn = UIButton.init("Close", fontSize: 14, textColor: .black, backgColor: .darkGray)
        pveBtn.frame = CGRect.init(x: 15, y: 15, width: 64, height: 40)
        view.addSubview(pveBtn)
        pveBtn.addTarget(self, action: #selector(didCloseGameBtnClick), for: .touchUpInside)
        /*--------------------------------------------*/
        
        
        /*--------------------------------------------*/
        
        
        /*--------------------------------------------*/
        let margin: CGFloat = MXSSize.Pw + 30.0
        passedView.frame = CGRect.init(x: margin, y: MXSSize.Hh + 5, width: MXSSize.Sw - margin * CGFloat(2), height: MXSSize.Ph)
        view.addSubview(passedView)
        /*--------------------------------------------*/
        let enterfaceView = UIView.init()
        enterfaceView.backgroundColor = UIColor.init(75, 80, 100)
        enterfaceView.frame = CGRect.init(x: 0, y: MXSSize.Sh - MXSSize.Hh + 15, width: MXSSize.Sw, height: MXSSize.Hh-15)
        view.addSubview(enterfaceView)
        /*--------                         ----------*/
        let middle_width:CGFloat = MXSSize.Sw - 10 - MXSSize.Hw - 10 - 10 - MXSSize.Hw
        let skill_width:CGFloat = MXSSize.Hw
        leadingView.frame = CGRect(x: 10 + MXSSize.Hw + 10, y: enterfaceView.frame.minY - 44, width: middle_width, height: 44)
        view.addSubview(leadingView)
        leadingView.belong = self
        
        playerView.frame = CGRect.init(x: 10, y: MXSSize.Sh - MXSSize.Hh, width: MXSSize.Hw, height: MXSSize.Hh)
        view.addSubview(playerView)
        playerView.controller = self
        self.heroConcreteView.append(playerView)
        
        graspPokerView.frame = CGRect.init(x: 10 + MXSSize.Hw + 10, y: MXSSize.Sh - (MXSSize.Ph + 5.0), width: middle_width, height: MXSSize.Ph + 5.0)
        view.addSubview(graspPokerView)
        graspPokerView.controller = self;
        
        skillDivView.backgroundColor = .brown
        skillDivView.frame = CGRect.init(x: MXSSize.Sw - skill_width, y: enterfaceView.frame.minY, width: skill_width, height: enterfaceView.frame.height)
        view.addSubview(skillDivView)
        /*--------------------------------------------*/
        
        view.addSubview(pickHeroView)
        pickHeroView.belong = self
    }
    
    func readyModelForView() {
        self.numberOfChair = 2
    }
    
    //MARK: - actions
    @objc func didCloseGameBtnClick() {
        MXSPokerCmd.shared.packagePoker()
        MXSJudge.cmd.gameOver()
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Pick hero
    public func pickedHero(_ hero:MXSHero, chairNumb:Int = 0) {
        
    }
    
    //MARK: - Skill
    public func layoutSkillViews(skilles:[MXSSkill]) {
        
        let btn_height:CGFloat = 40.0
        var height_sum:CGFloat = 5.0
        for skill in skilles {
            if skill.power == .blank || skill.power == .unKnown || skill.power == .lock { continue }
            let btn = MXSSkillBtn.init(skill:skill)
            btn.frame = CGRect(x: 5, y: height_sum, width: skillDivView.frame.width-10.0, height: btn_height)
            skillDivView.addSubview(btn)
            height_sum += btn_height+3
            btn.addTarget(self, action: #selector(didSkillBtnClick(btn:)), for: .touchUpInside)
        }
        skillDivView.contentSize = CGSize.init(width: 0, height: height_sum)
    }
    
    @objc func didSkillBtnClick(btn:MXSSkillBtn) {
        
    }
    
    //MARK: - leadingView
    public func certainForAttack() {
        leadingView.hide()
        
        MXSJudge.cmd.leader?.discardPoker(reBlock: { needWaiting, type, poker in
            if type == .passed {
                passedView.collectPoker(poker)
            }
            else if type == .handover {//= active give + responder gain
                
            }
            
            if needWaiting {
                self.checkResponderAndWaitReply()
            }
            else {
                MXSJudge.cmd.leaderReactive()
                leadingView.state = .attackUnPick
            }
        })
    }
    public func checkResponderAndWaitReply() { //sub object
        
    }
    
    public func cancelForAttack() {
        for poker in player.picked { poker.concreteView?.isUp = false }
        player.picked.removeAll()
        MXSJudge.cmd.clearResponder()
    }
        
    public func endActive() {
        leadingView.hide()
        
        passedView.fadeout()
        endLeaderCycle()
    }
    func endLeaderCycle() { //sub object
        MXSJudge.cmd.dealcardForNextLeader { hero, pokers in
            
        }
    }
    
    public func certainForDefense() {
        leadingView.hide()
        playerReplyAsResponder()
    }
    func playerReplyAsResponder() { //sub object
        
    }
        
    public func cancelForDefense() {
        leadingView.hide()
        playerDidntReply()
    }
    func playerDidntReply() { //sub object
        
    }
        
    override func playerCollectPoker(_ poker: MXSPoker) {
        player.getPokers([poker])
        poker.state = .handOn
//        newAndGraspMoreViews([poker])
    }
    
    
    //MARK: - poker
    @objc public func someonePokerTaped(_ pokerView: MXSPokerView) {
        //no action
        if player.holdAction == nil {
            MXSLog("player haven't action")
            return
        }
        
        if let index = player.ownPokers.firstIndex(where: {$0 === pokerView.belong}) {
            MXSLog("controller action pok at " + "\(index)")
        }
        
        pokerView.isUp = !pokerView.isUp
        let poker = pokerView.belong!
        if pokerView.isUp {
            player.pickPoker(poker)
        } else {
            player.freePoker(poker)
        }
        
        checkCanCertainAction()
    }
    
    //MARK: - hero
    public override func someoneHeroTaped(_ heroView: MXSHeroView) {
        MXSLog("controller action hero")
        //no action
        if player.holdAction == nil {
            MXSLog("player haven't action")
            return
        }
        //TODO: - tap oneself -> return
        
        let hero = heroView.belong!
        if heroView.signStatus == .selected {
            MXSJudge.cmd.removeResponder(hero)
        }
        else {
            MXSJudge.cmd.appendResponder(hero)
        }
        
        checkCanCertainAction()
    }
    
    //MARK: - check every one step action
    func checkCanCertainAction() {
        if player.signStatus == .selected {
            if MXSJudge.cmd.canDefence() {
                leadingView.state = .defenseReadyOn
            }
            else {
                leadingView.state = .defenseUnPick
            }
        }
        else {
            if MXSJudge.cmd.playerCanAttack() {
                leadingView.state = .attackReadyOn
            }
            else {
                if player.picked.count > 0 {
                    leadingView.state = .attackPicked
                }
                else { leadingView.state = .attackUnPick }
            }
        }
        
    }
    
    
    public func someHeroHPZero(_ hero:MXSHero) {
        MXSLog(hero.name, "Hero defalt")
        
        let alert = UIAlertController.init(title: "GameOver", message: hero.name+" defalt", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "ok", style: .cancel, handler: { (act) in
            self.didCloseGameBtnClick()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - application
    override var prefersStatusBarHidden: Bool {
        return true
    }

}
