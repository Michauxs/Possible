//
//  MXSRBlockController.swift
//  Possible
//
//  Created by Sunfei on 2024/4/9.
//  Copyright © 2024 boyuan. All rights reserved.
//

import UIKit

class MXSRBlockController: MXSViewController {
    
    let RBlockCmd :MXSRBlockCmd = MXSRBlockCmd(Sum_row: 16, Sum_col: 12)
    
    /**0.5s / v**/
    var velocity: Int = 2
    var isRun:Bool = false
    
    let blockGround: UIView = UIView()
    let GroundMask: UIView = UIView()
    
    var blockHolder: MXSRBlockItem?
    
    let summaryView: UIView = UIView()
    let summaryLabel = UILabel.init(text: "", fontSize: 614, textColor: .white, align: .center)
    
    var C_check = 0 {
        didSet {
            markCountLabel.text = "\(C_check)"
        }
    }
    let markCountLabel = UILabel(text: "0", fontSize: 314, textColor: .lightText, align: .left)
    
    
    //MARK: - Method
    override func packageFunctionName() {
//        MXSFuncMapCmd.functionMapVoid["timerCmdRunAction"] = timerCmdRunAction
//        MXSFuncMapCmd.functionVoid1 = timerCmdRunAction
    }
    
    var secondCount: Int = 0
    override func timerCmdRunAction() {
        if longPressLink == true {
            
        }
        
        if isRun == false { return }
        
        //MXSLog("----- timer 0.5 second -----")
        secondCount += 1
        if secondCount == velocity {
            //MXSLog("=============== timer 1 second ===============")
            self.sendRBlockItemMove(.down)
            secondCount = 0;
        }
    }
    
    func sendRBlockItemMove(_ direction: MoveDirection) {
        guard let holder = blockHolder else { return }
        RBlockCmd.supposingRBlockMove(RBlock: holder, move: direction, judge: { direction, result in
            switch result {
            case .driftdown:
                RBlockCmd.fillRBlock(holder, fill: false)
                holder.move(direction)
                RBlockCmd.fillRBlock(holder)
                self.refreshScreen()
            case .settledown:
                let rowArray = RBlockCmd.checkRow()
                if rowArray.count > 0 {
//                    isRun = false
//                    secondCount = 0
                    RBlockCmd.emptyRow(rowArray)
                    self.C_check += rowArray.count
                    //self.refreshScreen()
                }
                else {
                    
                }
                self.generateRBlockItem()
                
            case .barrier:
                break
            }
        })
    }
        
    func generateRBlockItem() {
        secondCount = 0
        //Int.random(in: 1...7)
        blockHolder = MXSRBlockItem.randomRBlock()
        
        guard let holder = blockHolder else { return }
        holder.coordinate = (0, 5)
        RBlockCmd.fillRBlock(holder)
        refreshScreen()
        
        if RBlockCmd.checkRBlockTouchingTop(holder) {
            isRun = false
            MXSTIPMaskCmd.shared.showMaskWithTip("Game Over!")
        }
    }
    
    var blockViewPackage = [MXSRBlockUnitView]()
    func refreshScreen() {
        for unit in blockViewPackage {
            unit.setSelect(RBlockCmd.filledTable[unit.idx]!.isFill)
        }
    }
    
    func setupMarkCounter(contentView: UIView) {
        contentView.addSubview(summaryLabel)
        summaryLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(12)
            make.centerX.equalTo(contentView)
        }

        let markTitle = UILabel(text: "☀️:", fontSize: 314, textColor: .white, align: .left)
        contentView.addSubview(markTitle)
        markTitle.snp.makeConstraints { make in
            make.left.equalTo(contentView).offset(10)
            make.bottom.equalTo(contentView).inset(10)
        }
        contentView.addSubview(markCountLabel)
        markCountLabel.snp.makeConstraints { make in
            make.left.equalTo(markTitle.snp_right).offset(3)
            make.centerY.equalTo(markTitle)
        }
    }
    
    let ground_padding = 10.0
    //MARK: - VC Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let groundH = MXSSize.Sh
        let block_w_h = groundH / CGFloat(RBlockCmd.Sum_row)
        let groundW = block_w_h * CGFloat(RBlockCmd.Sum_col)
        
        let margin_left = (MXSSize.Sw-groundW)*0.5
        
        
        let top_height: CGFloat = 44.0
        let topView = UIView.init()
        topView.backgroundColor = UIColor.init(75, 80, 100)
        topView.frame = CGRect.init(x: 0, y: 0, width: MXSSize.Sw, height: top_height)
        self.view.addSubview(topView)
        
        let closeBtn = UIButton.init("Close", fontSize: 14, textColor: .white, backgColor: .darkGray)
        closeBtn.frame = CGRect.init(x: 10, y: 0, width: 64, height: top_height)
        topView.addSubview(closeBtn)
        closeBtn.addTarget(self, action: #selector(didCloseGameBtnClick), for: .touchUpInside)
        
        let restartBtn = UIButton.init("Reset", fontSize: 14, textColor: .white, backgColor: .darkGray)
        restartBtn.frame = CGRect.init(x: MXSSize.Sw - 10 - 64, y: 0, width: 64, height: top_height)
        topView.addSubview(restartBtn)
        restartBtn.addTarget(self, action: #selector(didRestartBtnClick), for: .touchUpInside)
        let pauseBtn = UIButton.init("Pause", fontSize: 14, textColor: .white, backgColor: .darkGray)
        pauseBtn.setTitle("Resume", for: .selected)
        pauseBtn.frame = CGRect.init(x: restartBtn.frame.minX - 64 - 10, y: 0, width: 64, height: top_height)
        topView.addSubview(pauseBtn)
        pauseBtn.addTarget(self, action: #selector(didPauseBtnClick(btn:)), for: .touchUpInside)
        
        let gradeBtn = UIButton.init("Grade", fontSize: 14, textColor: .white, backgColor: .darkGray)
        gradeBtn.frame = CGRect.init(x: 10, y: top_height+10, width: margin_left - 10*2, height: top_height)
        self.view.addSubview(gradeBtn)
        gradeBtn.addTarget(self, action: #selector(didGradeBtnClick), for: .touchUpInside)
        
        /*--------------------------------------*/
        
        blockGround.frame = CGRect(x: margin_left, y: 0, width: groundW, height: groundH)
        blockGround.backgroundColor = .black
        self.view.addSubview(blockGround)
        GroundMask.frame = blockGround.frame
        GroundMask.backgroundColor = .clear
        self.view.addSubview(GroundMask)
        
        layoutblock()
        
        summaryView.frame = CGRect(x: blockGround.frame.maxX + 10, y: top_height + 20.0, width: margin_left - 20, height: 90)
        summaryView.backgroundColor = .black
        summaryView.setRaius(1.0, borderColor: .white, borderWitdh: 1.0)
        self.view.addSubview(summaryView)
        
        self.setupMarkCounter(contentView: summaryView)
        
        /*--------------------------------------*/
        let centerPoint:CGPoint = CGPoint(x: margin_left*0.5, y: MXSSize.Sh*0.5 + 50.0)
        let sk_width: CGFloat = 44.0
        let title = ["⬆️", "⬅️", "⬇️", "➡️"]
        for index in 0..<title.count {
            let dirtionBtn = UIButton.init(title[index], fontSize: 18, textColor: .white, backgColor: .darkGray)
            dirtionBtn.tag = index
            self.view.addSubview(dirtionBtn)
            let x = CGFloat(sin(Double.pi/2 * Double(index)))
            let y = CGFloat(cos(Double.pi/2 * Double(index)))
            dirtionBtn.bounds = CGRect.init(x: 0, y: 0, width: sk_width, height: sk_width)
            dirtionBtn.center = CGPoint(x: centerPoint.x - (sk_width+5.0)*x, y: centerPoint.y - (sk_width+5.0)*y)
            dirtionBtn.addTarget(self, action: #selector(didDirectionBtnClick(btn:)), for: .touchUpInside)
            
            // 添加手势识别器来处理双击
            let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didDirectionBtnLongPress(press:)))
            longPressGestureRecognizer.minimumPressDuration = 0.5
            longPressGestureRecognizer.allowableMovement = sk_width
            dirtionBtn.addGestureRecognizer(longPressGestureRecognizer)
        }
        /*--------------------------------------*/
        let btn_w_h = 64.0
        let markBtn = UIButton.init("🔄", fontSize: 625, textColor: .white, backgColor: .darkGray)
        markBtn.frame = CGRect.init(x: MXSSize.Sw - (margin_left + btn_w_h)*0.5, y: centerPoint.y - btn_w_h*0.5, width: btn_w_h, height: btn_w_h)
        self.view.addSubview(markBtn)
        markBtn.addTarget(self, action: #selector(didTransformBtnClick), for: .touchUpInside)
        
        /*--------------------------------------*/
        
        MXSTimerCmd.cmd.monitor(self)
        clearGroundGoOn()
    }
    
    func layoutblock() {
        
        summaryLabel.text = "Mission..."
        GroundMask.isHidden = true
        
        C_check = 0
        
        let space = 0.5
        let item_w = (blockGround.frame.size.height - space*CGFloat(RBlockCmd.Sum_row-1)) / CGFloat(RBlockCmd.Sum_row)
        for row in 0..<RBlockCmd.Sum_row {
            for col in 0..<RBlockCmd.Sum_col {
                let block = MXSRBlockUnitView(frame: CGRect(x: (item_w+space)*CGFloat(col), y: (item_w+space)*CGFloat(row), width: item_w, height: item_w))
                block.control = self
                block.coordinate = (row, col)
                blockGround.addSubview(block)
                blockViewPackage.append(block)
            }
        }
    }
    
    //MARK: - actions
    @objc func didDirectionBtnClick(btn:UIButton) {
        MXSLog("didDirecionBtnClick:" + "\(btn.tag)")
        if canUserInterface == false { return }
        if btn.tag == 0 {//up
            return
        }
        
        secondCount = 0
        
        let direct = MoveDirection(rawValue: btn.tag)
        self.sendRBlockItemMove(direct!)
    }
    @objc func didDirectionBtnLongPress(press: UILongPressGestureRecognizer) {
        if canUserInterface == false { return }
        
        guard let btn = press.view else { return }
        if btn.tag == 0 {//up
            return
        }
        
        if press.state == .began {
            MXSLog("didDirectionBtnLongPress begin : " + "\(btn.tag)")
            isRun = false
            
            longPressLink = true
            let direction = MoveDirection(rawValue: btn.tag)
            self.dLickMove(direction!)
        }
        else if press.state == .changed {
            MXSLog("nothing todo")
        }
        else {
            MXSLog("didDirectionBtnLongPress end : " + "\(btn.tag)")
            isRun = true
            secondCount = 0
            longPressLink = false
        }
    }
    
    
    var longPressLink = false
    func dLickMove(_ direction: MoveDirection) {
        self.sendRBlockItemMove(direction)
        
        if longPressLink {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250), execute: DispatchWorkItem(block: {
                self.dLickMove(direction)
            }))
        }
    }
    
    @objc func didTransformBtnClick() {
        if canUserInterface == false { return }
        
        guard let holder = blockHolder else { return }
        if RBlockCmd.supposingRBlockTransform(RBlock: holder) {
            RBlockCmd.fillRBlock(holder, fill: false)
            holder.transform()
            RBlockCmd.fillRBlock(holder)
            
            self.refreshScreen()
        }
    }
    
    @objc func didCloseGameBtnClick() {
        self.navigationController?.popViewController(animated: false)
    }
    @objc func didRestartBtnClick() {
        clearGroundGoOn()
    }
    var canUserInterface =  true
    @objc func didPauseBtnClick(btn:UIButton) {
        btn.isSelected = !btn.isSelected
        if btn.isSelected {
            isRun = false
            secondCount = 0
            canUserInterface = false
        }
        else {
            isRun = true
            canUserInterface = true
        }
    }
    
    @objc func didGradeBtnClick() {
        isRun = false
        let alert = UIAlertController.init(title: "Grade", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "Primary", style: .default, handler: { (act) in
            self.resetGrade(v: 3)
        }))
        alert.addAction(UIAlertAction.init(title: "Middle", style: .default, handler: { (act) in
            self.resetGrade(v: 2)
        }))
        alert.addAction(UIAlertAction.init(title: "High", style: .default, handler: { (act) in
            self.resetGrade(v: 1)
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: { (act) in
            self.isRun = true
        }))
        self.present(alert, animated: true, completion: nil)
    }
    func resetGrade(v: Int) {
        isRun = true
        velocity = v
        clearGroundGoOn()
    }
    func clearGroundGoOn() {
        RBlockCmd.clearAllFilled()
        isRun = true
        secondCount = 0
        generateRBlockItem()
    }
    
}
