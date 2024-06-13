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
    
    let layoutAnimateDuration:Double = 0.35
    /**丢牌定义reverse = lose+layout动画同步进行，0...reverse...*/
    func layoutPokerView(_ reverse:[Int] = [Int](), complete:(()->Void)?) {
        
        let count_poker = belong?.ownPokers.count ?? 0
        
        let count = PokerViewArray.count
        let need_width = MXSSize.Pw * CGFloat(count)
        let box_width = self.bounds.size.width
        
        var margin_base = MXSSize.Pw
        if need_width > box_width {
            margin_base = (box_width - MXSSize.Pw) / CGFloat(count_poker-1)
        }
        //如果折叠后每张所得显示区域太小，则强制重置展示宽度，并开启滚动
        if margin_base < MXSSize.PTextVerLimit { margin_base = MXSSize.PTextVerLimit }
        self.contentSize = CGSize.init(width: margin_base*CGFloat(count_poker-1) + MXSSize.Pw, height: 0)
        /*--------------------------*/
        
        if reverse.count == 0 {
            for index in 0..<count {
                let poker = belong!.ownPokers[index]
                poker.concreteView!.frame = CGRect(x: margin_base * CGFloat(index), y: self.PPedMargin, width: MXSSize.Pw, height: MXSSize.Ph)
                poker.concreteView?.showWidth = poker === belong?.ownPokers.last ? MXSSize.Pw : margin_base
            }
            
            if complete != nil {
                complete!()
            }
        }
        else {
            MXSLog(reverse, "pick poker.reverse")
            var count_resv: Int = 0
            
            for index in 0..<count {
                let pokerView = PokerViewArray[index]
                // 0...index...reverse...index..<count
                if reverse.contains(index) {
                    //up
                    count_resv += 1
                }
                else {
                    UIView.animate(withDuration: layoutAnimateDuration) {
                        pokerView.frame = CGRect(x: margin_base * CGFloat(index-count_resv), y: self.PPedMargin, width: MXSSize.Pw, height: MXSSize.Ph)
                    } completion: { complete in
                        
                    }
                }
                pokerView.showWidth = (index == count-1) ? MXSSize.Pw : margin_base
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(layoutAnimateDuration*1000)), execute: DispatchWorkItem(block: { [self] in
                for resv in reverse {
                    let pokerView = PokerViewArray[resv]
                    pokerView.removeFromSuperview()
                    PokerViewArray.remove(at: resv)
                }
                
                if complete != nil { complete!() }
            }))
        }
    }
    
//    let dispGroup = DispatchGroup.init()
//    dispGroup.enter()
//    dispGroup.leave()
//    dispGroup.notify(queue: .main) { [self] in
//    }
    var PokerViewArray:[MXSPokerView] = [MXSPokerView]()
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
                PokerViewArray.append(poker.concreteView!)
            }
        }
        
        layoutPokerView(complete: nil)
    }
    func delayExc() {
        
    }
    public func losePokerView( _ pokers:[MXSPoker], complete:(()->Void)?) {
        
        var indexSet = [Int]()
        for poker in pokers {
            
            if let index = PokerViewArray.firstIndex(of: poker.concreteView!) {
                indexSet.append(index)
            }
            
            let frame = poker.concreteView!.frame
            UIView.animate(withDuration: layoutAnimateDuration) {
                poker.concreteView!.frame = CGRect(x: frame.origin.x, y: -MXSSize.Ph, width: MXSSize.Pw, height: MXSSize.Ph)
            }
        }
        
        self.layoutPokerView(indexSet) {
            complete?()
        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
//            
//        }
        
    }
    
}
