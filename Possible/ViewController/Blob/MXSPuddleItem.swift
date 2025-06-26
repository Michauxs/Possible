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
    
    let CenterToEdgeDuration:Double = 0.45
    
    func boom(finish:@escaping ()->Void) {
        upLabel.center = CGPoint.init(x: self.frame.width*0.5, y: self.frame.height*0.5)
        leftLabel.center = CGPoint.init(x: self.frame.width*0.5, y: self.frame.height*0.5)
        downLabel.center = CGPoint.init(x: self.frame.width*0.5, y: self.frame.height*0.5)
        rightLabel.center = CGPoint.init(x: self.frame.width*0.5, y: self.frame.height*0.5)
        upLabel.isHidden = false
        leftLabel.isHidden = false
        downLabel.isHidden = false
        rightLabel.isHidden = false
        
        UIView.animate(withDuration: CenterToEdgeDuration) {
            self.upLabel.center = CGPoint.init(x: self.frame.width*0.5, y: 0)
            self.leftLabel.center = CGPoint.init(x: 0, y: self.frame.height*0.5)
            self.downLabel.center = CGPoint.init(x: self.frame.width*0.5, y: self.frame.height)
            self.rightLabel.center = CGPoint.init(x: self.frame.width, y: self.frame.height*0.5)
        } completion: { comp in
            self.upLabel.isHidden = true
            self.leftLabel.isHidden = true
            self.downLabel.isHidden = true
            self.rightLabel.isHidden = true
            finish()
        }
    }
    
    func collect(result:@escaping (_ boom:Bool, _ cross:FlowDirect?)->Void) {
        self.state = self.state + 1
        if self.state == 5 {
            self.state = 0
            self.boom {
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
    
    //MARK: - 流入
    func inflow(from:MXSPuddleItem, finish:@escaping (_ boom:Bool, _ cross:FlowDirect?)->Void) {
        let direct = direct(forItem: from) //水流向
        
        switch direct {
        case .up:
            upLabel.center = CGPoint.init(x: self.frame.width*0.5, y: self.frame.height)
            upLabel.isHidden = false
        case .left:
            leftLabel.center = CGPoint.init(x: self.frame.width, y: self.frame.height*0.5)
            leftLabel.isHidden = false
        case .down:
            downLabel.center = CGPoint.init(x: self.frame.width*0.5, y: 0)
            downLabel.isHidden = false
        case .right:
            rightLabel.center = CGPoint.init(x: 0, y: self.frame.height*0.5)
            rightLabel.isHidden = false
        }
        UIView.animate(withDuration: CenterToEdgeDuration) {
            switch direct {
            case .up:
                self.upLabel.center = CGPoint.init(x: self.frame.width*0.5, y: self.frame.height*0.5)
            case .left:
                self.leftLabel.center = CGPoint.init(x: self.frame.width*0.5, y: self.frame.height*0.5)
            case .down:
                self.downLabel.center = CGPoint.init(x: self.frame.width*0.5, y: self.frame.height*0.5)
            case .right:
                self.rightLabel.center = CGPoint.init(x: self.frame.width*0.5, y: self.frame.height*0.5)
            }
        } completion: { comp in
            switch direct {
            case .up:
                self.upLabel.isHidden = true
            case .left:
                self.leftLabel.isHidden = true
            case .down:
                self.downLabel.isHidden = true
            case .right:
                self.rightLabel.isHidden = true
            }
            
            if self.state == 0 {//空水洼->outflow
                self.outflow(direct: direct) {
                    finish(false, direct)
                }
            }
            else {
                self.state = self.state + 1
                if self.state == 5 {
                    self.state = 0
                    self.boom {
                        finish(true, nil)
                    }
                }
                else {
                    finish(false, nil)
                }
            }
            
        }
    }
    
    //MARK: - 流出
    func outflow(direct:FlowDirect, outed:@escaping ()->Void) {
        switch direct {
        case .up:
            upLabel.center = CGPoint.init(x: self.frame.width*0.5, y: self.frame.height*0.5)
            upLabel.isHidden = false
        case .left:
            leftLabel.center = CGPoint.init(x: self.frame.width*0.5, y: self.frame.height*0.5)
            leftLabel.isHidden = false
        case .down:
            downLabel.center = CGPoint.init(x: self.frame.width*0.5, y: self.frame.height*0.5)
            downLabel.isHidden = false
        case .right:
            rightLabel.center = CGPoint.init(x: self.frame.width*0.5, y: self.frame.height*0.5)
            rightLabel.isHidden = false
        }
        UIView.animate(withDuration: CenterToEdgeDuration) {
            switch direct {
            case .up:
                self.upLabel.center = CGPoint.init(x: self.frame.width*0.5, y: 0)
            case .left:
                self.leftLabel.center = CGPoint.init(x: 0, y: self.frame.height*0.5)
            case .down:
                self.downLabel.center = CGPoint.init(x: self.frame.width*0.5, y: self.frame.height)
            case .right:
                self.rightLabel.center = CGPoint.init(x: self.frame.width, y: self.frame.height*0.5)
            }
        } completion: { comp in
            switch direct {
            case .up:
                self.upLabel.isHidden = true
            case .left:
                self.leftLabel.isHidden = true
            case .down:
                self.downLabel.isHidden = true
            case .right:
                self.rightLabel.isHidden = true
            }
            outed()
        }
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
    
    let upLabel = UILabel.init(text: "*", fontSize: 614, textColor: .white, align: .center)
    let leftLabel = UILabel.init(text: "*", fontSize: 614, textColor: .white, align: .center)
    let downLabel = UILabel.init(text: "*", fontSize: 614, textColor: .white, align: .center)
    let rightLabel = UILabel.init(text: "*", fontSize: 614, textColor: .white, align: .center)
    
    let titleLabel = UILabel.init(text: "", fontSize: 614, textColor: .darkText, align: .center)
    override func setupSubviews() {
        
        self.backgroundColor = .gray
        addSubview(titleLabel)
        titleLabel.frame = self.bounds
//        titleLabel.snp.makeConstraints({ make in
//            make.center.equalTo(self)
//        })
        
//        let attributedString = NSAttributedString(string: "*", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
//        let size = CGSize(width: 200, height: 200)
//        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
//        let boundingRect = attributedString.boundingRect(with: size, options: options, context: nil).size
        /**
         - width : 6.453125
         - height : 16.70703125
         */
        let frame = CGRect(x: 0, y: 0, width: 6.46, height: 16.71)
        upLabel.frame = frame
        leftLabel.frame = frame
        downLabel.frame = frame
        rightLabel.frame = frame
        addSubview(upLabel)
        addSubview(leftLabel)
        addSubview(downLabel)
        addSubview(rightLabel)
        self.upLabel.isHidden = true
        self.leftLabel.isHidden = true
        self.downLabel.isHidden = true
        self.rightLabel.isHidden = true
        
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
    /**
     func inflow(from:MXSPoolWaterItem, finish:@escaping (_ cross:DropDirect?)->Void) {
         let direct = diret(forItem: from)
         
         switch direct {
         case .up:
             upLabel.center = CGPoint.init(x: self.frame.width*0.5, y: self.frame.height)
             upLabel.isHidden = false
         case .left:
             leftLabel.center = CGPoint.init(x: self.frame.width, y: self.frame.height*0.5)
             leftLabel.isHidden = false
         case .down:
             downLabel.center = CGPoint.init(x: self.frame.width*0.5, y: 0)
             downLabel.isHidden = false
         case .right:
             rightLabel.center = CGPoint.init(x: 0, y: self.frame.height*0.5)
             rightLabel.isHidden = false
         case .all: break
         }
         UIView.animate(withDuration: CenterToEdgeDuration) {
             switch direct {
             case .up:
                 if stay { self.upLabel.center = CGPoint.init(x: self.frame.width*0.5, y: self.frame.height*0.5) }
                 else { self.upLabel.center = CGPoint.init(x: self.frame.width*0.5, y: 0) }
                 
             case .left:
                 if stay { self.leftLabel.center = CGPoint.init(x: self.frame.width*0.5, y: self.frame.height*0.5) }
                 else { self.leftLabel.center = CGPoint.init(x: 0, y: self.frame.height*0.5) }
             case .down:
                 if stay { self.downLabel.center = CGPoint.init(x: self.frame.width*0.5, y: self.frame.height*0.5) }
                 else { self.downLabel.center = CGPoint.init(x: self.frame.width*0.5, y: self.frame.height) }
             case .right:
                 if stay { self.rightLabel.center = CGPoint.init(x: self.frame.width*0.5, y: self.frame.height*0.5) }
                 else { self.rightLabel.center = CGPoint.init(x: self.frame.width, y: self.frame.height*0.5) }
             case .all:
                 break
             }
         } completion: { comp in
             switch direct {
             case .up:
                 self.upLabel.isHidden = true
             case .left:
                 self.leftLabel.isHidden = true
             case .down:
                 self.downLabel.isHidden = true
             case .right:
                 self.rightLabel.isHidden = true
             case .all: break
             }
             
             if stay {
                 finish(nil)
             }
             else {
                 finish(direct)
             }
             
         }
     }
     
     */
}
