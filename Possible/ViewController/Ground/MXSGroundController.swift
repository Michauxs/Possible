//
//  MXSGroundController.swift
//  HaiOn
//
//  Created by Sunfei on 2020/8/12.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit


class MXSGroundController: MXSViewController {
    
    let PPedMargin: CGFloat = 5.0
    
    var player: MXSHero = MXSHeroCmd.shared.getNewBlankHero()
    var opponter: MXSHero = MXSHeroCmd.shared.getNewBlankHero()
    
    var graspPokerView: MXSGraspPokerView?
    
    var skillScrollView: UIScrollView = UIScrollView.init()
    let pickHeroView = MXSPickHeroView.init(frame: CGRect.init(x: 0, y: 0, width: MXSSize.Sw, height: MXSSize.Sh))
    
    lazy var leadingView: MXSLeadingView = {
        let leader = MXSLeadingView.init()
        let pokerViewFrame = graspPokerView!.frame
        leader.frame = CGRect(x: pokerViewFrame.minX, y: pokerViewFrame.minY - 44, width: pokerViewFrame.width, height: 44)
        view.addSubview(leader)
        leader.belong = self
        return leader
    }()
    
    lazy var passedView: MXSPassedView = {
        let view_pass = MXSPassedView.init()
        let margin: CGFloat = MXSSize.Pw + 30.0
        view_pass.frame = CGRect.init(x: margin, y: MXSSize.Hh + 5, width: MXSSize.Sw - margin * CGFloat(2), height: MXSSize.Ph)
        view.addSubview(view_pass)
        return view_pass
    }()
    
    lazy var maskView: UIView = {
        let mask = UIView.init(frame: view.bounds)
        mask.backgroundColor = .clear
        return mask
    }()
    var userEnable: Bool = true {
        didSet {
            self.maskView.isHidden = userEnable
        }
    }
    
    @objc func didCloseGameBtnClick() {
        MXSPokerCmd.shared.packagePoker()
        MXSJudge.cmd.gameOver()
        self.navigationController?.popViewController(animated: true)
    }
    
    let playerView = MXSHeroView.init()
    let oppontView = MXSHeroView.init()
    public func pickedHero(_ hero:MXSHero, isOpponter:Bool = false) {
        
    }
    
    public func layoutSkillViews(skilles:[MXSSkill]) {
        
        let btn_height:CGFloat = 40.0
        var height_sum:CGFloat = 5.0
        for skill in skilles {
            if skill.power == .blank || skill.power == .unKnown || skill.power == .lock { continue }
            let btn = MXSSkillBtn.init(skill:skill)
            btn.frame = CGRect(x: 5, y: height_sum, width: skillScrollView.frame.width-10.0, height: btn_height)
            skillScrollView.addSubview(btn)
            height_sum += btn_height+3
            btn.addTarget(self, action: #selector(didSkillBtnClick(btn:)), for: .touchUpInside)
        }
        skillScrollView.contentSize = CGSize.init(width: 0, height: height_sum)
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
        
        self.initionalSubViewes()
        /*--------------------------------------------*/
        self.readyModelForView()
    }
        
    func initionalSubViewes() {
        let pveBtn = UIButton.init("Close", fontSize: 14, textColor: .black, backgColor: .darkGray)
        pveBtn.frame = CGRect.init(x: 15, y: 15, width: 64, height: 40)
        view.addSubview(pveBtn)
        pveBtn.addTarget(self, action: #selector(didCloseGameBtnClick), for: .touchUpInside)
        
        let actionBg = UIView.init()
        actionBg.backgroundColor = UIColor.init(75, 80, 100)
        actionBg.frame = CGRect.init(x: 0, y: MXSSize.Sh - MXSSize.Hh + 15, width: MXSSize.Sw, height: MXSSize.Hh-15)
        self.view.addSubview(actionBg)
        
        /*--------------------------------------------*/
        self.view.addSubview(playerView)
        playerView.frame = CGRect.init(x: 10, y: MXSSize.Sh - MXSSize.Hh, width: MXSSize.Hw, height: MXSSize.Hh)
        playerView.controller = self
        /*--------------------------------------------*/
        
        self.view.addSubview(oppontView)
        oppontView.frame = CGRect(x: (MXSSize.Sw - MXSSize.Hw)*0.5, y: 0, width: MXSSize.Hw, height: MXSSize.Hh)
        oppontView.controller = self
        /*--------------------------------------------*/
        skillScrollView.backgroundColor = .brown
        skillScrollView.frame = CGRect.init(x: MXSSize.Sw-MXSSize.Hw, y: actionBg.frame.minY, width: MXSSize.Hw, height: actionBg.frame.height)
        view.addSubview(skillScrollView)
        
        /*--------------------------------------------*/
        graspPokerView = MXSGraspPokerView.init(frame: CGRect.init(x: playerView.frame.maxX+10,
                                                                    y: MXSSize.Sh - (MXSSize.Ph + PPedMargin),
                                                                    width: MXSSize.Sw - 10 - MXSSize.Hw - 10 - 10 - MXSSize.Hw,
                                                                    height: MXSSize.Ph + PPedMargin),
                                                 controller: self)
        view.addSubview(graspPokerView!)
        
        /*--------------------------------------------*/
        pickHeroView.frame = self.view.bounds
        view.addSubview(pickHeroView)
        pickHeroView.belong = self
    }
    
    func readyModelForView() {
        
    }
    
    
    //MARK: - Skill
    @objc func didSkillBtnClick(btn:MXSSkillBtn) {
        
    }
    
    //MARK: - leadingView
    public func certainForAttack() {
        leadingView.hide()
        
        let waiting = MXSJudge.cmd.leader?.discardPoker(reBlock: { type, poker in
            if type == .passed {
                passedView.collectPoker(poker)
            }
            else if type == .handover {//= active give + responder gain
                
            }
        })
        
        if waiting! { self.waitingResponerReply() }
        else {
            MXSJudge.cmd.leaderReactive()
            leadingView.state = .attackUnPick
        }
    }
    public func waitingResponerReply() { //sub object
        
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
        
//        MXSJudge.cmd.
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
            return }
        
        if let index = player.holdPokers.firstIndex(where: {$0 === pokerView.belong}) {
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
        if player.holdAction == nil { return }
        
        MXSJudge.cmd.leader?.takeOrDisAimAtHero(heroView.belong!)
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
        
        let alert = UIAlertController.init(title: "GameOver", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "get", style: .cancel, handler: { (act) in
            self.didCloseGameBtnClick()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - application
    override var prefersStatusBarHidden: Bool {
        return true
    }

}
