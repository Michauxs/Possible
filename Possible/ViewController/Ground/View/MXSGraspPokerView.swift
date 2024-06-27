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
    func layoutPokerView( complete:(()->Void)?) {
        let count_poker = belong!.ownPokers.count
        if count_poker < 1 {
            complete?()
            return
        }
        
        if count_poker == 1 {
            let poker = belong!.ownPokers.first!
            poker.concreteView!.frame = CGRect(x: 0, y: self.PPedMargin, width: MXSSize.Pw, height: MXSSize.Ph)
            poker.concreteView?.showWidth = MXSSize.Pw
            complete?()
            return
        }
        
        
        let need_width = MXSSize.Pw * CGFloat(count_poker)
        let box_width = self.bounds.size.width
        
        var margin_base = MXSSize.Pw
        if need_width > box_width {
            margin_base = (box_width - MXSSize.Pw) / CGFloat(count_poker-1)
        }
        //如果折叠后每张所得显示区域太小，则强制重置展示宽度，并开启滚动
        if margin_base < MXSSize.PTextVerLimit { margin_base = MXSSize.PTextVerLimit }
        self.contentSize = CGSize.init(width: margin_base*CGFloat(count_poker-1) + MXSSize.Pw, height: 0)
        /*--------------------------*/
        
        for index in 0..<count_poker {
            let poker = belong!.ownPokers[index]
            UIView.animate(withDuration: layoutAnimateDuration) {
                poker.concreteView?.frame = CGRect(x: margin_base * CGFloat(index), y: self.PPedMargin, width: MXSSize.Pw, height: MXSSize.Ph)
                poker.concreteView?.showWidth = (index == count_poker-1) ? MXSSize.Pw : margin_base
            }
            offset_x = poker.concreteView!.frame.minX
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(layoutAnimateDuration*1000)), execute: DispatchWorkItem(block: { [self] in
            complete?()
        }))
    }
    
//    let dispGroup = DispatchGroup.init()
//    dispGroup.enter()
//    dispGroup.leave()
//    dispGroup.notify(queue: .main) { [self] in
//    }
    
    var offset_x: CGFloat = 0.0
    public func holdPokerView( _ pokers:[MXSPoker], complete:(()->Void)?) {
        
        for poker in pokers {
            if poker.concreteView == nil {
                poker.concreteView = MXSPokerView.init(control: self.controller!)
            }
            poker.concreteView!.frame = CGRect(x: offset_x, y: -MXSSize.Ph, width: MXSSize.Pw, height: MXSSize.Ph)
            self.addSubview(poker.concreteView!)
        }
        
        layoutPokerView(complete: complete)
    }
    
    public func losePokerView( _ pokers:[MXSPoker], complete:(()->Void)?) {
        /**由接收处管理pokerView的动画和转移**/
        ///其他完全不用管，包括移除view  ——view在的上层frame，需要此时的子frame转换。所以此时不能移除
        ///此处只负责动画剩下的view
        self.layoutPokerView(complete: complete)
    }
    
}
