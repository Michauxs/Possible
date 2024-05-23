//
//  MXSRBlockController.swift
//  Possible
//
//  Created by Sunfei on 2024/4/9.
//  Copyright © 2024 boyuan. All rights reserved.
//

import UIKit

class MXSRBlockController: MXSViewController {
    
    var numberOfRow = 16
    var numberOfCol = 12
    var velocity = 1.5
    var isRun:Bool = false
    
    let blockGround: UIView = UIView()
    let GroundMask: UIView = UIView()
    var blockPackage = [MXSRBlockUnitView]()
    var filledTable = [Int:Bool]()
    var blockHolder: MXSRBlockItem?
    
    let summaryView: UIView = UIView()
    let summaryLabel = UILabel.init(text: "", fontSize: 614, textColor: .white, align: .center)
    
    var S_block = 0
    var C_mark_real = 0
    var C_mark = 0 {
        didSet {
            MXSLog("block mark count: " + "\(C_mark)")
            markCountLabel.text = String(C_mark)
        }
    }
    var C_check = 0
    let markCountLabel = UILabel(text: "0", fontSize: 314, textColor: .lightText, align: .left)
    let blockSumLabel = UILabel(text: "0", fontSize: 314, textColor: .lightText, align: .left)
    
    
    //MARK: - Method
    override func packageFunctionName() {
        functionMapVoid["timerCmdRunAction"] = timerCmdRunAction
    }
    var secondCount: Int = 0
    func timerCmdRunAction() {
        if isRun == false {
            return
        }
        MXSLog("timer 0.5 second")
        secondCount += 1
        if secondCount == 2 {
            MXSLog("========== timer 1 second ==========")
            self.moveRBlockItem(.down)
            self.refreshScreen()
            secondCount = 0;
        }
    }
    
    @objc func didCloseGameBtnClick() {
        self.navigationController?.popViewController(animated: false)
    }
    @objc func didRestartBtnClick() {
        clearGroundGoOn()
    }
    
    @objc func didGradeBtnClick() {
        let alert = UIAlertController.init(title: "Grade", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "Primary", style: .default, handler: { (act) in
            self.resetGrade(v: 2.0)
        }))
        alert.addAction(UIAlertAction.init(title: "Middle", style: .default, handler: { (act) in
            self.resetGrade(v: 1.5)
        }))
        alert.addAction(UIAlertAction.init(title: "High", style: .default, handler: { (act) in
            self.resetGrade(v: 1.0)
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: { (act) in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }

    func resetGrade(v: CGFloat) {
        velocity = v
        clearGroundGoOn()
    }
    func clearGroundGoOn() {
        for key in Array(filledTable.keys) {
            filledTable[key] = false
        }
        
        generateRBlockItem()
        isRun = true
        refreshScreen()
        
    }
    func generateRBlockItem() {
        
        blockHolder = MXSRBlockItem(item: .armLeft)
        guard let holder = blockHolder else { return }
        
        holder.coordinate = (0, 5)
        
        for coor in holder.unitSet {
            let unit = (holder.coordinate.0 + coor.0, holder.coordinate.1 + coor.1)
            filledTable[unit.0*100+unit.1] = true
        }
    }
    func refreshScreen() {
        for unit in blockPackage {
            unit.setSelect(filledTable[unit.idx]!)
        }
    }
    func moveRBlockItem(_ direction: MoveDirection) {
        guard let holder = blockHolder else { return }
        
        for coor in holder.unitSet {
            let unit = (holder.coordinate.0 + coor.0, holder.coordinate.1 + coor.1)
            filledTable[unit.0*100+unit.1] = false
        }
        
        holder.move(direction)
        
        for coor in holder.unitSet {
            let unit = (holder.coordinate.0 + coor.0, holder.coordinate.1 + coor.1)
            filledTable[unit.0*100+unit.1] = true
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
        let block_w_h = groundH / CGFloat(numberOfRow)
        let groundW = block_w_h * CGFloat(numberOfCol)
        
        let margin_left = (MXSSize.Sw-groundW)*0.5
        
        
        let top_height: CGFloat = 44.0
        let topView = UIView.init()
        topView.backgroundColor = UIColor.init(75, 80, 100)
        topView.frame = CGRect.init(x: 0, y: 0, width: MXSSize.Sw, height: top_height)
        self.view.addSubview(topView)
        
        let closeBtn = UIButton.init("Close", fontSize: 14, textColor: .white, backgColor: .darkGray)
        closeBtn.frame = CGRect.init(x: 10, y: 0, width: 64, height: top_height)
        self.view.addSubview(closeBtn)
        closeBtn.addTarget(self, action: #selector(didCloseGameBtnClick), for: .touchUpInside)
        
        let restartBtn = UIButton.init("Reset", fontSize: 14, textColor: .white, backgColor: .darkGray)
        restartBtn.frame = CGRect.init(x: MXSSize.Sw - 10 - 64, y: 0, width: 64, height: top_height)
        self.view.addSubview(restartBtn)
        restartBtn.addTarget(self, action: #selector(didRestartBtnClick), for: .touchUpInside)
        
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
            let dirtionBtn = UIButton.init(title[index], fontSize: 14, textColor: .white, backgColor: .darkGray)
            dirtionBtn.tag = index
            self.view.addSubview(dirtionBtn)
            let x = CGFloat(sin(Double.pi/2 * Double(index)))
            let y = CGFloat(cos(Double.pi/2 * Double(index)))
            dirtionBtn.bounds = CGRect.init(x: 0, y: 0, width: sk_width, height: sk_width)
            dirtionBtn.center = CGPoint(x: centerPoint.x - (sk_width+5.0)*x, y: centerPoint.y - (sk_width+5.0)*y)
            dirtionBtn.addTarget(self, action: #selector(didDirectionBtnClick(btn:)), for: .touchUpInside)
        }
        /*--------------------------------------*/
        let btn_w_h = 64.0
        let markBtn = UIButton.init("@", fontSize: 625, textColor: .white, backgColor: .darkGray)
        markBtn.frame = CGRect.init(x: MXSSize.Sw - (margin_left + btn_w_h)*0.5, y: centerPoint.y - btn_w_h*0.5, width: btn_w_h, height: btn_w_h)
        self.view.addSubview(markBtn)
        markBtn.addTarget(self, action: #selector(didSignBtnClick), for: .touchUpInside)
        
        /*--------------------------------------*/
        MXSTimerCmd.cmd.monitor(self)
        clearGroundGoOn()
    }
    
    func layoutblock() {
        
        summaryLabel.text = "Mission..."
        GroundMask.isHidden = true
        C_mark = 0
        C_check = 0
        S_block = 0
        C_mark_real = 0
        
        let space = 0.5
        let item_w = (blockGround.frame.size.height - space*CGFloat(numberOfRow-1)) / CGFloat(numberOfRow)
        for row in 0..<numberOfRow {
            for col in 0..<numberOfCol {
                let block = MXSRBlockUnitView(frame: CGRect(x: (item_w+space)*CGFloat(col), y: (item_w+space)*CGFloat(row), width: item_w, height: item_w))
                block.control = self
                block.coordinate = (row, col)
                blockGround.addSubview(block)
                blockPackage.append(block)
                filledTable[block.idx] = false
            }
        }
        
        blockSumLabel.text = String(S_block)
    }
    
    @objc func didDirectionBtnClick(btn:UIButton) {
        MXSLog("didDirecionBtnClick:")
        
        
    }
    
    @objc func didSignBtnClick() {
        guard blockHolder != nil else { return }
        
        
    }
    
    func endMission(complete: Bool) {
        
    }
    
    //MARK: - common
    
    
}
