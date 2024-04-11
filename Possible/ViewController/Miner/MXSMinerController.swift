//
//  MXSMinerController.swift
//  Possible
//
//  Created by Sunfei on 2024/4/9.
//  Copyright © 2024 boyuan. All rights reserved.
//

import UIKit

class MXSMinerController: MXSViewController {
    
    let numberOfRow = 15
    let mineGround: UIView = UIView()
    let GroundMask: UIView = UIView()
    var minePackage = [MXSMineItemView]()
    var mineHolder: MXSMineItemView?
    
    let summaryView: UIView = UIView()
    let summaryLabel = UILabel.init(text: "", fontSize: 616, textColor: .lightText, align: .center)
    
    var S_mine = 0
    var CountCheck = 0
    var CountDone = 0
    
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
        functionMapPara["mineViewTaped:"] = mineViewTaped
    }
    
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
        /*--------------------------------------*/
        
        mineGround.frame = CGRect(x: margin_left, y: 0, width: groundWH, height: groundWH)
        mineGround.backgroundColor = .black
        self.view.addSubview(mineGround)
        GroundMask.frame = mineGround.frame
        GroundMask.backgroundColor = .clear
        self.view.addSubview(GroundMask)
        
        layoutMine()
        
        summaryView.frame = CGRect(x: mineGround.frame.maxX, y: top_height + 50.0, width: margin_left, height: 80)
        summaryView.backgroundColor = .black
        self.view.addSubview(summaryView)
        summaryLabel.frame = CGRect.init(x: 0, y: 0, width: margin_left, height: 50)
        summaryView.addSubview(summaryLabel)
        
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
        
        let removeBtn = UIButton.init("🚩", fontSize: 14, textColor: .white, backgColor: .darkGray)
        removeBtn.frame = CGRect.init(x: mineGround.frame.maxX + 15.0, y: centerPoint.y - 22, width: 50, height: 44)
        self.view.addSubview(removeBtn)
        removeBtn.addTarget(self, action: #selector(didSignBtnClick), for: .touchUpInside)
        
        let doneBtn = UIButton.init("#", fontSize: 614, textColor: .white, backgColor: .darkGray)
        doneBtn.frame = CGRect.init(x: removeBtn.frame.maxX + 10.0, y: removeBtn.frame.minY, width: 50, height: 44)
        self.view.addSubview(doneBtn)
        doneBtn.addTarget(self, action: #selector(didDoneBtnClick), for: .touchUpInside)
        /*--------------------------------------*/
//        view.addSubview(nameLabel)
//        nameLabel.frame = CGRect(x: mainTable!.frame.maxX+15, y: top_height+15, width: 100, height: 20)
        
        /*--------------------------------------*/
    }
    
    func layoutMine() {
        for mine in minePackage {
            mine.removeFromSuperview()
        }
        minePackage.removeAll()
        
        summaryView.isHidden = true
        GroundMask.isHidden = true
        S_mine = 0
        CountCheck = 0
        CountDone = 0
        
        let space = 0.5
        let item_w = (mineGround.frame.size.width - space*CGFloat(numberOfRow-1)) / CGFloat(numberOfRow)
        for row in 0..<numberOfRow {
            for col in 0..<numberOfRow {
                let mine = MXSMineItemView.init(control: self)
                mine.frame = CGRect.init(x: (item_w+space)*CGFloat(col), y: (item_w+space)*CGFloat(row), width: item_w, height: item_w)
                mine.info = ["row":row, "col":col]
                mineGround.addSubview(mine)
                minePackage.append(mine)
                
                if Int.random(in: 1...10) == 1 {
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
        
        mineHolder?.state = .check
        if mineHolder!.isBoom {
            CountCheck += 1
            
            if CountCheck == S_mine {
                endMission(complete: true)
            }
        }
    }
    @objc func didDoneBtnClick() {
        MXSLog("didDoneBtnClick")
        guard mineHolder != nil else { return }
        
        if mineHolder?.state == .done { return }
        
        if mineHolder!.isBoom {
            mineHolder?.state = .boom
            endMission(complete: false)
        }
        else {
            mineHolder?.state = .done
            CountDone += 1
            checkAround(view: mineHolder!)
        }
    }
    
    func checkAround(view: MXSMineItemView) {
        
        let tupleArray = [(view.row-1, view.col-1), (view.row-1, view.col), (view.row-1, view.col+1),
                          (view.row, view.col-1), (view.row, view.col+1),
                          (view.row+1, view.col-1), (view.row+1, view.col), (view.row+1, view.col+1)]
        
        var neighbors = [MXSMineItemView]()
        for tuple in tupleArray {
            if let anyone = findAnyoneMineView(row: tuple.0, col: tuple.1) {
                if anyone.state != .done { neighbors.append(anyone) }
            }
        }
        
        //var diffuse = true
        var count = 0
        for mine in neighbors {
            if (mine.isBoom) {
                count += 1
            }
        }
        
        if count == 0 {
            for mine in neighbors {
                mine.state = .done
                CountDone += 1
                
                if CountDone == numberOfRow*numberOfRow - S_mine {
                    endMission(complete: true)
                }
                else {
                    GroundMask.isHidden = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
                        self.checkAround(view: mine)
                        self.GroundMask.isHidden = true
                    }
                }
            }
        }
        else {
            view.clue = count
        }
        
    }
    
    func findAnyoneMineView(row:Int, col:Int) -> MXSMineItemView? {
        if row >= numberOfRow || row < 0 || col >= numberOfRow || col < 0 {
            return nil
        }
        return minePackage[row*numberOfRow+col]
    }
    
    func endMission(complete: Bool) {
        mineHolder = nil
        summaryLabel.text = complete ? "Mission Complete" : "Mission Failed"
        summaryView.isHidden = false
        GroundMask.isHidden = false
    }
    
    //MARK: - notifies
    @objc func collectionDidSelectedItem(args:Array<Any>) {
        
    }
    
    
}
