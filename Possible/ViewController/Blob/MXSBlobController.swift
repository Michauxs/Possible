//
//  MXSBlobController.swift
//  Possible
//
//  Created by Sunfei on 2025/3/28.
//  Copyright © 2025 boyuan. All rights reserved.
//

import UIKit

class MXSBlobController: MXSViewController {
    
    var numberOfRow = 6
    let groundView: UIView = UIView()
    let GroundMask: UIView = UIView()
    var puddlePackage = [MXSPuddleItem]()
    var puddleHolder: MXSPuddleItem?
    
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
        
        /*--------------------------------------*/
        
        groundView.frame = CGRect(x: margin_left, y: 0, width: groundWH, height: groundWH)
        groundView.backgroundColor = .black
        self.view.addSubview(groundView)
        GroundMask.frame = groundView.frame
        GroundMask.backgroundColor = .clear
        self.view.addSubview(GroundMask)
        
        layoutPool()
        
        /*--------------------------------------*/
    }
    
    func layoutPool() {
        for puddle in puddlePackage {
            puddle.removeFromSuperview()
        }
        puddlePackage.removeAll()
        
        GroundMask.isHidden = true

        let space = 1.0
        let item_w = (groundView.frame.size.width - space*CGFloat(numberOfRow-1)) / CGFloat(numberOfRow)
        for row in 0..<numberOfRow {
            for col in 0..<numberOfRow {
                let puddle = MXSPuddleItem(frame: CGRect(x: (item_w+space)*CGFloat(col), y: (item_w+space)*CGFloat(row), width: item_w, height: item_w))
                puddle.owner = self
                puddle.info = (row, col)
                groundView.addSubview(puddle)
                puddlePackage.append(puddle)
                
                puddle.state = Int.random(in: 0...4)
            }
        }
        
    }
    
    
    
    //MARK: - Method
    @objc func didCloseGameBtnClick() {
        self.navigationController?.popViewController(animated: false)
    }
    @objc func didRestartBtnClick() {
        self.layoutPool()
    }
    
    func puddleItemTaped(args: Any) {
        let item = args as! MXSPuddleItem
        puddleHolder = item
        item.collect { boom, cross in
            if boom {
                self.nebghborsItemCollectBlob(item: item)
            }
        }
    }
    
    //传递1-主体自发寻找四周邻体
    func nebghborsItemCollectBlob(item:MXSPuddleItem) {
        let nebs = self.getNebghbors(item)
        for neb in nebs {
            neb.inflow(from: item) { [self] boom, cross in
                self.inflowed(item: neb, boom: boom, cross: cross)
            }//
        }
    }
    //传递2-穿越体寻找流出方向的邻体
    func nebghborMoveon(item:MXSPuddleItem, direct:FlowDirect) {
        if let anyone = adjacentNebghbor(item, direct: direct) {
            anyone.inflow(from: item) { [self] boom, cross in
                self.inflowed(item: anyone, boom: boom, cross: cross)
            }
        }
    }
    //回归
    func inflowed(item:MXSPuddleItem, boom:Bool, cross:FlowDirect?) {
        if boom {
            nebghborsItemCollectBlob(item: item)
        }
        else {
            if cross != nil {
                self.nebghborMoveon(item: item, direct: cross!)
            }
        }
    }
    
    func resetGradeLayoutMIne(row: Int, rang: Int) {
        numberOfRow = row
        layoutPool()
    }
    
    func endMission(complete: Bool) {
        
        GroundMask.isHidden = false
        
    }
    
    //MARK: - common
    func adjacentNebghbor(_ item: MXSPuddleItem, direct:FlowDirect) -> MXSPuddleItem? {
        var tuple:(Int, Int)
        switch direct {
        case .up:
            tuple = (item.row-1, item.col)
        case .left:
            tuple = (item.row, item.col-1)
        case .down:
            tuple = (item.row+1, item.col)
        case .right:
            tuple = (item.row, item.col+1)
        }
        return findAnyonePuddle(row: tuple.0, col: tuple.1)
    }
    
    
    func getNebghbors(_ view: MXSPuddleItem) -> [MXSPuddleItem] {
        let tupleArray = [(view.row-1, view.col),
                          (view.row, view.col-1), (view.row, view.col+1),
                          (view.row+1, view.col)]
        var neighbors = [MXSPuddleItem]()
        for tuple in tupleArray {
            if let anyone = findAnyonePuddle(row: tuple.0, col: tuple.1) {
                neighbors.append(anyone)
            }
        }
        return neighbors
    }
    func findAnyonePuddle(row:Int, col:Int) -> MXSPuddleItem? {
        if row >= numberOfRow || row < 0 || col >= numberOfRow || col < 0 {
            return nil
        }
        return puddlePackage[row*numberOfRow+col]
    }
    
    
}
