//
//  graspPokerView.swift
//  Possible
//
//  Created by Sunfei on 2022/4/15.
//  Copyright © 2022 boyuan. All rights reserved.
//

import UIKit

class MXSGraspPokerView: UIScrollView  {
    
    weak var controller:MXSGroundController?
    weak var belong:MXSHero?
    
    let PPedMargin: CGFloat = 5.0
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        self.frame = frame
        self.showsHorizontalScrollIndicator = false
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    let layoutAnimateDuration:Double = 0.5
    func layoutPokerView(_ reserve:Int = 0, complete:(()->Void)?) {
//        let _ = self.subviews.map { subv in
//            subv.removeFromSuperview()
//        }
        
        let count = belong?.ownPokers.count ?? 0
        let need_width = MXSSize.Pw * CGFloat(count)
        let box_width = self.bounds.size.width
        
        var margin_base = MXSSize.Pw
        if need_width > box_width {
            margin_base = (box_width - MXSSize.Pw) / CGFloat(count-1)
        }
        //如果折叠后每张所得显示区域太小，则强制重置展示宽度，并开启滚动
        if margin_base < MXSSize.PTextVerLimit { margin_base = MXSSize.PTextVerLimit }
        self.contentSize = CGSize.init(width: margin_base*CGFloat(count-1) + MXSSize.Pw, height: 0)
        /*--------------------------*/
        
        if reserve == 0 {
            for index in 0..<count {
                let poker = belong!.ownPokers[index]
                poker.concreteView!.frame = CGRect(x: margin_base * CGFloat(index), y: self.PPedMargin, width: MXSSize.Pw, height: MXSSize.Ph)
                poker.concreteView?.showWidth = poker === belong?.ownPokers.last ? MXSSize.Pw : margin_base
            }
            
            if complete != nil { complete!() }
        }
        else {
            
            let dispGroup = DispatchGroup.init()
            for index in 0..<count {
                let poker = belong!.ownPokers[index]
                
                if index < count-reserve {
                    dispGroup.enter()
                    UIView.animate(withDuration: layoutAnimateDuration) {
                        poker.concreteView!.frame = CGRect(x: margin_base * CGFloat(index), y: self.PPedMargin, width: MXSSize.Pw, height: MXSSize.Ph)
                    } completion: { complete in
                        dispGroup.leave()
                    }
                }
                else {
                    poker.concreteView!.frame = CGRect(x: margin_base * CGFloat(index), y: -MXSSize.Ph, width: MXSSize.Pw, height: MXSSize.Ph)
                }
                poker.concreteView?.showWidth = poker === belong?.ownPokers.last ? MXSSize.Pw : margin_base
                
            }
            
            dispGroup.notify(queue: .main) {
                if complete != nil { complete!() }
            }
        }
        
        
    }
    
    public func collectPoker( _ pokers:[MXSPoker]) {
//        if !belong?.isAxle { return }
        
        for poker in pokers {
            if poker.concreteView == nil {
                //poker.concreteView = MXSPokerView.init(poker: poker, controller: self.controller)
//                poker.concreteView = MXSPokerView.init(controller: self.controller)
                poker.concreteView = MXSPokerView.init(control: self.controller!)
                //poker.concreteView!.controller = self.controller
                poker.concreteView!.frame = CGRect(x: 0, y: self.PPedMargin, width: MXSSize.Pw, height: MXSSize.Ph)
                self.addSubview(poker.concreteView!)
            }
        }
        
        if pokers.count == belong?.ownPokers.count {
            layoutPokerView(complete: nil)
        }
        else {
            self.layoutPokerView(pokers.count) {
                let owns = self.belong!.ownPokers
                for index in owns.count-pokers.count ..< owns.count {
                    let poker = owns[index]
                    
                    let frame = poker.concreteView!.frame
                    UIView.animate(withDuration: 0.25) {
                        poker.concreteView!.frame = CGRect(x: frame.origin.x, y: self.PPedMargin, width: MXSSize.Pw, height: MXSSize.Ph)
                    }
                }
            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(layoutAnimateDuration*1000)) { [self] in
//            }
//            self.perform(Selector("delayExc"), with: nil, afterDelay: 0.5)
            //StrideSwift 的stride函数返回一个任意可变步长类型值(int, float等等)的序列
        }
    }
    func delayExc() {
        
    }
    public func losePokerView( _ pokers:[MXSPoker], complete:(()->Void)?) {
//        if !belong?.isAxle { return }
        
        for poker in pokers {
            let frame = poker.concreteView!.frame
            UIView.animate(withDuration: 0.5) {
                poker.concreteView!.frame = CGRect(x: frame.origin.x, y: -MXSSize.Ph, width: MXSSize.Pw, height: MXSSize.Ph)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            self.layoutPokerView {
                
                complete?()
            }
//            if complete != nil { complete!() }
        }
        
    }
    
}
