//
//  MXSMinerController.swift
//  Possible
//
//  Created by Sunfei on 2024/4/9.
//  Copyright © 2024 boyuan. All rights reserved.
//

import UIKit

class MXSMinerController: MXSViewController {
    
    var numberOfRow = 14
    var possibleRang = 8
    let mineGround: UIView = UIView()
    let GroundMask: UIView = UIView()
    var minePackage = [MXSMineItemView]()
    var mineHolder: MXSMineItemView?
    
    let summaryView: UIView = UIView()
    let summaryLabel = UILabel.init(text: "", fontSize: 614, textColor: .white, align: .center)
    let summaryFace = UILabel.init(text: "", fontSize: 616, textColor: .lightText, align: .center)
    
    var S_mine = 0
    var C_mark_real = 0
    var C_mark = 0 {
        didSet {
            MXSLog("mine mark count: " + "\(C_mark)")
            markCountLabel.text = String(C_mark)
        }
    }
    var C_check = 0
    let markCountLabel = UILabel(text: "0", fontSize: 314, textColor: .lightText, align: .left)
    let mineSumLabel = UILabel(text: "0", fontSize: 314, textColor: .lightText, align: .left)
    
    let mineTest = MXSMineItemView()
    
    //MARK: - Method
    @objc func didCloseGameBtnClick() {
        self.navigationController?.popViewController(animated: false)
    }
    @objc func didRestartBtnClick() {
        self.layoutMine()
    }
    
    func mineViewTaped(args: Any) {
        MXSLog("mineViewTaped")
        let view = args as! MXSMineItemView
        if (mineHolder != nil) { mineHolder!.selected = false }
        view.selected = true
        mineHolder = view
    }
    override func packageFunctionName() {
        MXSFuncMapCmd.functionMapPara["mineViewTaped:"] = mineViewTaped
    }
    
    @objc func didGradeBtnClick() {
        let alert = UIAlertController.init(title: "Grade", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "Primary", style: .default, handler: { (act) in
            self.resetGradeLayoutMIne(row: 10, rang: 9)
        }))
        alert.addAction(UIAlertAction.init(title: "Middle", style: .default, handler: { (act) in
            self.resetGradeLayoutMIne(row: 14, rang: 8)
        }))
        alert.addAction(UIAlertAction.init(title: "High", style: .default, handler: { (act) in
            self.resetGradeLayoutMIne(row: 18, rang: 7)
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: { (act) in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    @objc func didCustomBtnClick() {
        let alert = UIAlertController.init(title: "Custom", message: "", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "SumBlock: x * x"
            textField.keyboardType = .numberPad
        }
        alert.addTextField { textField in
            textField.placeholder = "Possible: 1 / x"
            textField.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: { (act) in
            
        }))
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (act) in
            let textField0 = alert.textFields![0]
            let textField1 = alert.textFields![1]
            
//            var row = 2
//            var possible = 2
//            if textField0.text != nil { row = Int(textField0.text!)! }
//            if textField1.text != nil { possible = Int(textField1.text!)! }
            
            let input0: String = textField0.text!
            let input1: String = textField1.text!
            let row: Int? = Int(input0)
            let rang: Int? = Int(input1)
            if row != nil && rang != nil {
                self.resetGradeLayoutMIne(row: row!, rang: rang!)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    func resetGradeLayoutMIne(row: Int, rang: Int) {
        numberOfRow = row
        possibleRang = rang
        layoutMine()
    }
    func setupMarkCounter(contentView: UIView) {
        contentView.addSubview(summaryLabel)
        summaryLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(12)
            make.centerX.equalTo(contentView)
        }
        contentView.addSubview(summaryFace)
        summaryFace.snp.makeConstraints { make in
            make.top.equalTo(summaryLabel.snp_bottom).offset(5)
            make.centerX.equalTo(contentView)
        }
        
        let markTitle = UILabel(text: "🚩:", fontSize: 314, textColor: .white, align: .left)
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
        
        let sumTitle = UILabel(text: "💣:", fontSize: 314, textColor: .white, align: .left)
        contentView.addSubview(sumTitle)
        sumTitle.snp.makeConstraints { make in
            make.left.equalTo(markCountLabel.snp_right).offset(20)
            make.centerY.equalTo(markTitle)
        }
        contentView.addSubview(mineSumLabel)
        mineSumLabel.snp.makeConstraints { make in
            make.left.equalTo(sumTitle.snp_right).offset(3)
            make.centerY.equalTo(markTitle)
        }
        
        
    }
    
    let ground_padding = 10.0
    //MARK: - VC Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let groundWH = MXSSize.Sh
        let margin_left = (MXSSize.Sw-groundWH)*0.5
        
        
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
        
        let customBtn = UIButton.init("Custom", fontSize: 14, textColor: .white, backgColor: .darkGray)
        customBtn.frame = CGRect.init(x: gradeBtn.frame.minX, y: gradeBtn.frame.maxY+5, width: gradeBtn.frame.width, height: gradeBtn.frame.size.height)
        self.view.addSubview(customBtn)
        customBtn.addTarget(self, action: #selector(didCustomBtnClick), for: .touchUpInside)
        /*--------------------------------------*/
        
        mineGround.frame = CGRect(x: margin_left, y: 0, width: groundWH, height: groundWH)
        mineGround.backgroundColor = .black
        self.view.addSubview(mineGround)
        GroundMask.frame = mineGround.frame
        GroundMask.backgroundColor = .clear
        self.view.addSubview(GroundMask)
        
        layoutMine()
        
        summaryView.frame = CGRect(x: mineGround.frame.maxX + 10, y: top_height + 20.0, width: margin_left - 20, height: 90)
        summaryView.backgroundColor = .black
        summaryView.setRaius(1.0, borderColor: .white, borderWitdh: 1.0)
        self.view.addSubview(summaryView)
        
        self.setupMarkCounter(contentView: summaryView)
        
//        mineTest.frame = CGRect(x: 10, y: 50, width: 80, height: 80)
//        view.addSubview(mineTest)
//        mineTest.control = self
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
        let markBtn = UIButton.init("🚩", fontSize: 14, textColor: .white, backgColor: .darkGray)
        markBtn.frame = CGRect.init(x: mineGround.frame.maxX + 15.0, y: centerPoint.y - 22, width: 50, height: 44)
        self.view.addSubview(markBtn)
        markBtn.addTarget(self, action: #selector(didSignBtnClick), for: .touchUpInside)
        
        let doneBtn = UIButton.init("#", fontSize: 614, textColor: .white, backgColor: .darkGray)
        doneBtn.frame = CGRect.init(x: markBtn.frame.maxX + 10.0, y: markBtn.frame.minY, width: 50, height: 44)
        self.view.addSubview(doneBtn)
        doneBtn.addTarget(self, action: #selector(didCheckBtnClick), for: .touchUpInside)
        
        let checkAroundBtn = UIButton.init("@@", fontSize: 614, textColor: .white, backgColor: .darkGray)
        checkAroundBtn.frame = CGRect.init(x: markBtn.frame.minX, y: markBtn.frame.maxY + 20, width: 50, height: 44)
        self.view.addSubview(checkAroundBtn)
//        checkAroundBtn.addTarget(self, action: #selector(didCheckAroundBtnClick), for: .touchUpInside)
        
        // 添加手势识别器来处理双击
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didCheckAroundBtnClick))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        checkAroundBtn.addGestureRecognizer(doubleTapGestureRecognizer)
        /*--------------------------------------*/
    }
    
    func layoutMine() {
        for mine in minePackage {
            mine.removeFromSuperview()
        }
        minePackage.removeAll()
        summaryLabel.text = "Mission..."
        summaryFace.text = "👓"
        GroundMask.isHidden = true
        C_mark = 0
        C_check = 0
        S_mine = 0
        C_mark_real = 0
        
        let space = 0.5
        let item_w = (mineGround.frame.size.width - space*CGFloat(numberOfRow-1)) / CGFloat(numberOfRow)
        for row in 0..<numberOfRow {
            for col in 0..<numberOfRow {
                let mine = MXSMineItemView(frame: CGRect(x: (item_w+space)*CGFloat(col), y: (item_w+space)*CGFloat(row), width: item_w, height: item_w))
                mine.owner = self
                mine.info = ["row":row, "col":col]
                mineGround.addSubview(mine)
                minePackage.append(mine)
                
                if Int.random(in: 1...possibleRang) == 1 {
                    mine.isBoom = true
                    S_mine += 1
                }
                
                mine.position = .center
                if (row == 0 && col == 0) || (row == 0 && col == numberOfRow-1) || (row == numberOfRow-1 && col == 0) || (row == numberOfRow-1 && col == numberOfRow-1) {
                    mine.position = .corner
                }
                else if row == 0 || col == 0 || row == numberOfRow-1 || col == numberOfRow-1 {
                    mine.position = .edge
                }
            }
        }
        
        mineSumLabel.text = String(S_mine)
    }
    
    @objc func didDirectionBtnClick(btn:UIButton) {
        MXSLog("didDirecionBtnClick:")
        guard mineHolder != nil else { return }
        var row_will = mineHolder!.row
        var col_will = mineHolder!.col
        if btn.tag == 0 {//up
            row_will -= 1
        }
        else if btn.tag == 1 {//left
            col_will -= 1
        }
        else if btn.tag == 2 {//down
            row_will += 1
        }
        else if btn.tag == 3 {//right
            col_will += 1
        }
        
        if row_will >= numberOfRow || row_will < 0 || col_will >= numberOfRow || col_will < 0 {
            return
        }
        
        let view = minePackage[row_will*numberOfRow+col_will]
        self.mineViewTaped(args: view)
    }
    
    @objc func didSignBtnClick() {
        guard mineHolder != nil else { return }
        
        if mineHolder?.state == .mark { //undo
            mineHolder?.setupState(.unknown)
            C_mark = C_mark-1
            if mineHolder!.isBoom {  C_mark_real -= 1 }
            return
        }
        
        mineHolder?.setupState(.mark)
        C_mark = C_mark+1
        if mineHolder!.isBoom {  C_mark_real += 1
            
            if C_mark_real == S_mine {
                endMission(complete: true)
            }
        }
    }
    @objc func didCheckBtnClick() {
        MXSLog("didCheckBtnClick")
        guard mineHolder != nil else { return }
        
        if mineHolder?.state == .check || mineHolder?.state == .mark { return }
        
        if mineHolder!.isBoom {
            mineHolder?.setupState(.boom)
            endMission(complete: false)
        }
        else {
            mineHolder?.setupState(.check)
            C_check += 1
            seekClueFromAround(view: mineHolder!)
        }
    }
    
    func seekClueFromAround(view: MXSMineItemView) {
        let neighbors = getNebghbors(view)
        //var diffuse = true
        var C_clue = 0
        for mine in neighbors {
            if (mine.isBoom) {
                C_clue += 1
            }
        }
        
        if C_clue == 0 {
            for mine in neighbors {
                if mine.state == .check { continue }
                
                mine.setupState(.check)
                C_check += 1
                
                if C_check == numberOfRow*numberOfRow - S_mine {
                    endMission(complete: true)
                    break
                }
                else {
                    GroundMask.isHidden = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                        self.seekClueFromAround(view: mine)
                        self.GroundMask.isHidden = true
                    }
                }
            }
        }
        else {
            view.clue = C_clue
        }
    }
    
    @objc func didCheckAroundBtnClick() {
        if mineHolder?.state != .check { return }
        
        let neighbors = getNebghbors(mineHolder!)
        for neighbor in neighbors {
            if neighbor.state == .check || neighbor.state == .mark { continue }
            
            if neighbor.isBoom {
                neighbor.setupState(.boom)
                endMission(complete: false)
                break
            }
            else {
                neighbor.setupState(.check)
                C_check += 1
                seekClueFromAround(view: neighbor)
            }
            
        }
    }
    
    
    func endMission(complete: Bool) {
        mineHolder?.selected = false
        mineHolder = nil
        summaryLabel.text = complete ? "Mission Complete!" : "Mission Failed!"
        summaryFace.text = complete ? "😊" : "😫"
        
        GroundMask.isHidden = false
        
        for mine in minePackage {
            if mine.isBoom {
                if (mine.state == .mark) {
                    mine.setupState(.show)
                }
                else {
                    mine.setupState(.boom)
                }
            }
        }
    }
    
    //MARK: - common
    func getNebghbors(_ view: MXSMineItemView) -> [MXSMineItemView] {
        let tupleArray = [(view.row-1, view.col-1), (view.row-1, view.col), (view.row-1, view.col+1),
                          (view.row, view.col-1), (view.row, view.col+1),
                          (view.row+1, view.col-1), (view.row+1, view.col), (view.row+1, view.col+1)]
        var neighbors = [MXSMineItemView]()
        for tuple in tupleArray {
            if let anyone = findAnyoneMineView(row: tuple.0, col: tuple.1) {
                neighbors.append(anyone)
            }
        }
        return neighbors
    }
    func findAnyoneMineView(row:Int, col:Int) -> MXSMineItemView? {
        if row >= numberOfRow || row < 0 || col >= numberOfRow || col < 0 {
            return nil
        }
        return minePackage[row*numberOfRow+col]
    }
    
    
}
