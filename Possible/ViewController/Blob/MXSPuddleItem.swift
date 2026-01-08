//
//  MXSBlobCountItem.swift
//  Possible
//
//  Created by Sunfei on 2025/3/28.
//  Copyright © 2025 boyuan. All rights reserved.
//

import UIKit

enum FlowDirect : Int {
    case up = 1
    case left = 2
    case down = 3
    case right = 4
}

class MXSPuddleItem: MXSBaseView {
    weak var owner: MXSBlobController?
    
    let CenterToEdgeDuration:Double = 0.25
    
    func isFilled(finish:@escaping ()->Void) {
        
        let tmp = [getIdelLabel(), getIdelLabel(), getIdelLabel(), getIdelLabel()]
        for label in tmp {
            label.center = point_center
        }
        
        UIView.animate(withDuration: CenterToEdgeDuration) {
            for index in 0...3 { //..<
                tmp[index].center = self.edgePointArray[index]
            }
        } completion: { comp in
            for label in tmp {
                label.isHidden = true
            }
            finish()
        }
    }
    
    func collectBlob(result:@escaping (_ boom:Bool, _ cross:FlowDirect?)->Void) {
        self.state = self.state + 1
        if self.state == 5 {
            self.state = 0
            self.isFilled {
                result(true, nil)
            }
        }
        else {
            result(false, nil)
        }
//        if poor == nil {//manual
//        }
//        else {//auto
//            inflow(from: poor!) { boom, cross in
//                result(boom, cross)
//            }
//        }
    }
    
    var edgePointArray:[CGPoint] = []
    
    //MARK: - 流入/经
    func inflow(from:MXSPuddleItem, finish:@escaping (_ boom:Bool, _ cross:FlowDirect?)->Void) {
        let direct = direct(forItem: from) //水流向
        
        let idleLabel = getIdelLabel()
        switch direct {
        case .up:
            idleLabel.center = edgePointArray[2]
        case .left:
            idleLabel.center = edgePointArray[3]
        case .down:
            idleLabel.center = edgePointArray[0]
        case .right:
            idleLabel.center = edgePointArray[1]
        }
        idleLabel.isHidden = false
        
        if self.state == 0 {//空水洼->outflow
            var point_cross = CGPointZero
            switch direct {
            case .up:
                point_cross = edgePointArray[0]
            case .left:
                point_cross = edgePointArray[1]
            case .down:
                point_cross = edgePointArray[2]
            case .right:
                point_cross = edgePointArray[3]
            }
            UIView.animate(withDuration: CenterToEdgeDuration*2) {
                idleLabel.center = point_cross
            } completion: { comp in
                idleLabel.isHidden = true
                finish(false, direct)
            }
        }
        else {
            UIView.animate(withDuration: CenterToEdgeDuration) {
                idleLabel.center = self.point_center
            } completion: { comp in
                idleLabel.isHidden = true
                
                self.state = self.state + 1
                if self.state == 5 {
                    self.state = 0
                    self.isFilled {
                        finish(true, nil)
                    }
                }
                else {
                    finish(false, nil)
                }
            }
        }
    }
    
    func getIdelLabel()->UILabel {
        if let index = dropArray.firstIndex(where: { (label) -> Bool in label.isHidden == true }) {
            let label = dropArray[index]
            label.isHidden = false
            return label
        }
//        let attributedString = NSAttributedString(string: "*", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
//        let size = CGSize(width: 200, height: 200)
//        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
//        let boundingRect = attributedString.boundingRect(with: size, options: options, context: nil).size
        /** '*' fontsize:14
         - width : 6.453125
         - height : 16.70703125
         */
        let label = UILabel.init(text: "*" + String(dropArray.count), fontSize: 614, textColor: .white, align: .center)
        label.frame = CGRect(x: 0, y: 0, width: 16.46, height: 16.71)
        addSubview(label)
        dropArray.append(label)
        return label
    }
    //MARK: - tools method
    /**水流向**/
    func direct(forItem:MXSPuddleItem)->FlowDirect {
        if self.row == forItem.row {
            if self.col > forItem.col {
                return .right
            }
            else { return .left }
        }
        else {//.col == .col
            if self.row > forItem.row {
                return .down
            }
            else { return .up }
        }
    }
    
    //MARK: - UI
    var row : Int = 0
    var col : Int = 0
    var idx : Int = 0
    var state : Int = 0 { //0...5
        didSet {
            titleLabel.text = String(state)
            titleLabel.isHidden = state == 0
        }
    }
    
    
    var dropArray:[UILabel] = []
    let titleLabel = UILabel.init(text: "", fontSize: 614, textColor: .darkText, align: .center)
    var point_center = CGPointZero
    
    override func setupSubviews() {
        
        self.backgroundColor = .gray
        addSubview(titleLabel)
        titleLabel.frame = self.bounds
        
        point_center = CGPoint.init(x: self.frame.width*0.5, y: self.frame.height*0.5)
        edgePointArray.append(CGPoint.init(x: self.frame.width*0.5, y: 0))
        edgePointArray.append(CGPoint.init(x: 0, y: self.frame.height*0.5))
        edgePointArray.append(CGPoint.init(x: self.frame.width*0.5, y: self.frame.height))
        edgePointArray.append(CGPoint.init(x: self.frame.width, y: self.frame.height*0.5))
        
        self.setUserInteraction()
        self.clipsToBounds = false;
    }
    
    override func selfTaped() {
//        self.control?.MXSFuncMapCmd.callFunction(byName: "mineViewTaped:", withPara: self)
        self.owner?.puddleItemTaped(args: self)
    }
    
    
    override var info: Any? {
        didSet {
            //
            let tuple = info as! (Int, Int)
            let row = tuple.0
            let col = tuple.1
            
            self.row = row
            self.col = col
            self.idx = row * 10 + col
        }
    }
    
}
