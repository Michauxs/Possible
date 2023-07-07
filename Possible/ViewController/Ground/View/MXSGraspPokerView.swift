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
    
    func layoutPokerView(_ reserve:Int = 0) {
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
        
        for index in 0..<count {
            let poker = belong!.ownPokers[index]
            
            if index < count-reserve {
                UIView.animate(withDuration: 0.5) {
                    poker.concreteView!.frame = CGRect(x: margin_base * CGFloat(index), y: self.PPedMargin, width: MXSSize.Pw, height: MXSSize.Ph)
                }
            }
            else {
                poker.concreteView!.frame = CGRect(x: margin_base * CGFloat(index), y: -MXSSize.Ph, width: MXSSize.Pw, height: MXSSize.Ph)
            }
                
            
            poker.concreteView?.showWidth = poker === belong?.ownPokers.last ? MXSSize.Pw : margin_base
        }
    }
    
    public func collectPoker( _ pokers:[MXSPoker]) {
//        if !belong?.isAxle { return }
        
        for poker in pokers {
            if poker.concreteView == nil {
                //poker.concreteView = MXSPokerView.init(poker: poker, controller: self.controller)
//                poker.concreteView = MXSPokerView.init(controller: self.controller)
                poker.concreteView = MXSPokerView.init()
                poker.concreteView!.controller = self.controller
                self.addSubview(poker.concreteView!)
            }
        }
        
        if pokers.count == belong?.ownPokers.count {
            layoutPokerView()
        }
        else {
            self.layoutPokerView(pokers.count)
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) { [self] in
                for index in belong!.ownPokers.count-pokers.count ..< belong!.ownPokers.count {
                    let poker = belong!.ownPokers[index]
                    
                    let frame = poker.concreteView!.frame
                    UIView.animate(withDuration: 0.25) {
                        poker.concreteView!.frame = CGRect(x: frame.origin.x, y: self.PPedMargin, width: MXSSize.Pw, height: MXSSize.Ph)
                    }
                }
            }
        }
    }
    public func losePoker( _ pokers:[MXSPoker]) {
//        if !belong?.isAxle { return }
        
        for poker in pokers {
            let frame = poker.concreteView!.frame
            UIView.animate(withDuration: 0.25) {
                poker.concreteView!.frame = CGRect(x: frame.origin.x, y: -MXSSize.Ph, width: MXSSize.Pw, height: MXSSize.Ph)
            }
            poker.concreteView!.removeFromSuperview()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            self.layoutPokerView()
        }
        
    }
    
}
