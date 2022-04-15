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
    
    var pokerScrollView: MXSGraspPokerView?
    
    /**pokerScrollView.subviews中的pokerview**/
    var graspPokerViewes: Array<MXSPokerView> = Array<MXSPokerView>()
    
    var skillScrollView: UIScrollView = UIScrollView.init()
    let pickHeroView = MXSPickHeroView.init(frame: CGRect.init(x: 0, y: 0, width: MXSSize.Sw, height: MXSSize.Sh))
    
    lazy var leadingView: MXSLeadingView = {
        let leader = MXSLeadingView.init()
        let pokerViewFrame = pokerScrollView!.frame
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
        player.pokers.removeAll()
        opponter.pokers.removeAll()
        MXSPokerCmd.shared.packagePoker()
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
        /*--------------------------------------------*/
        
        self.view.addSubview(oppontView)
        oppontView.frame = CGRect(x: (MXSSize.Sw - MXSSize.Hw)*0.5, y: 0, width: MXSSize.Hw, height: MXSSize.Hh)
        oppontView.controller = self
        /*--------------------------------------------*/
        skillScrollView.backgroundColor = .brown
        skillScrollView.frame = CGRect.init(x: MXSSize.Sw-MXSSize.Hw, y: actionBg.frame.minY, width: MXSSize.Hw, height: actionBg.frame.height)
        view.addSubview(skillScrollView)
        
        /*--------------------------------------------*/
        pokerScrollView = MXSGraspPokerView.init(frame: CGRect.init(x: playerView.frame.maxX+10,
                                                                    y: MXSSize.Sh - (MXSSize.Ph + PPedMargin),
                                                                    width: MXSSize.Sw - 10 - MXSSize.Hw - 10 - 10 - MXSSize.Hw,
                                                                    height: MXSSize.Ph + PPedMargin),
                                                 controller: self)
        view.addSubview(pokerScrollView!)
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
        leadingView.isHidden = true
        
        let poker = player.pickes.first!
        player.pokers.removeAll(where: {$0 === poker})
        poker.state = .pass
        
        pokerScrollView!.removePoker(pokers: player.pickes)
        passedView.collectPoker(pokers: player.pickes)
        
        self.updateViewsWaitOpponterRespon()
    }
    public func updateViewsWaitOpponterRespon() {
        
    }
    
    public func cancelPickes() {
        for poker in player.pickes { poker.concreteView?.isUp = false }
        player.pickes.removeAll()
        MXSJudge.cmd.clearPassive()
    }
        
    public func endActive() {
        leadingView.isHidden = true
        leadingView.state = .defenseUnPick
        
        MXSJudge.cmd.next()
        passedView.fadeout()
    }
    
    public func certainForDefense() {
        MXSJudge.cmd.leaderReactive()
        leadingView.isHidden = true
        
    }
    public func cancelForDefense() {
        if player.pickes.count != 0 {
            for poker in player.pickes { poker.concreteView?.isUp = false }
            player.pickes.removeAll()
        }
        
        let action = MXSJudge.cmd.leaderActiveAction
        if action == PokerAction.attack || action == PokerAction.warFire || action == PokerAction.arrowes {
            player.minsHP()
        }
        if action == PokerAction.steal {
            let index = Int(arc4random_uniform(UInt32(player.pokers.count)))
            let poker_random = player.pokers.remove(at: index)
            
            player.pokers.removeAll(where: {$0 === poker_random})
            pokerScrollView!.removePoker(pokers: [poker_random])
            
            opponter.pokers.append(poker_random)
        }
        if action == PokerAction.destroy {
            let index = Int(arc4random_uniform(UInt32(player.pokers.count)))
            let poker_random = player.pokers.remove(at: index)
            
            player.pokers.removeAll(where: {$0 === poker_random})
            pokerScrollView!.removePoker(pokers: [poker_random])
        }
        
        MXSJudge.cmd.leaderReactive()
        leadingView.isHidden = true
    }
        
    override func playerCollectPoker(_ poker: MXSPoker) {
        player.pokers.append(poker)
        poker.state = .handOn
//        newAndGraspMoreViews([poker])
    }
    
    
    //MARK: - poker
    @objc public func someonePokerTaped(_ pokerView: MXSPokerView) {
        if let index = player.pokers.firstIndex(where: {$0 === pokerView.belong}) {
            print("controller action pok at " + "\(index)")
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
        print("controller action hero")
        /**被动响应 无需选择*/
        if leadingView.state == LeadingState.defenseUnPick { return }
        
        MXSJudge.cmd.appendOrRemovePassive(heroView.belong!)
        checkCanCertainAction()
    }
    
    // MARK: - check every one step action
    func checkCanCertainAction() {
        if player.signStatus == .focus {
            if MXSJudge.cmd.passiveCanDefense() {
                leadingView.state = .defenseReadyOn
            }
            else {
                leadingView.state = .defenseUnPick
            }
        }
        else {
            if MXSJudge.cmd.leaderCanAttack() {
                leadingView.state = .attackReadyOn
            }
            else {
                if player.pickes.count > 0 {
                    leadingView.state = .attackPicked
                }
                else { leadingView.state = .attackUnPick }
            }
        }
        
    }
    
    //MARK: - application
    override var prefersStatusBarHidden: Bool {
        return true
    }

}
