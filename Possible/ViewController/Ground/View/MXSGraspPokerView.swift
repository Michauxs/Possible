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
    var graspPokeres: Array<MXSPoker> = Array<MXSPoker>()
    let PPedMargin: CGFloat = 5.0
    
    init(frame:CGRect, controller:MXSGroundController) {
        self.controller = belong
        self.frame = frame
        self.showsHorizontalScrollIndicator = false
    }
    
    public func appendPoker(pokers:Array<MXSPoker>) {
        graspPokeres.append(contentsOf: pokers)
    }
    public func removePoker(pokers:Array<MXSPoker>) {
        if pokers.count < 1 { return }
        
        for poker in pokers {
            graspPokeres.removeAll(where: {$0 == poker})
        }
    }
    
    
    func layoutPokerView() {
        let count = graspPokeres.count
        let need_width = MXSSize.Pw * CGFloat(count)
        let box_width = self.bounds.size.width
        
        let margin_base = MXSSize.Pw
        if need_width > box_width {
            margin_base = (box_width - MXSSize.Pw) / CGFloat(count-1)
        }
        //如果折叠后每张所得显示区域太小，则强制重置展示宽度，并开启滚动
        if margin_base < MXSSize.PTextVerLimit { margin_base = MXSSize.PTextVerLimit }
        self.contentSize = CGSize.init(width: margin_base*CGFloat(count-1) + MXSSize.Pw, height: 0)
        /*--------------------------*/
        
        for index in 0..<graspPokeres.count-1 {
            let pok = graspPokeres[index]
            if pok.concreteView == nil {
                pok.concreteView = MXSPokerView.init()
            }
            pok.concreteView!.removeFromSuperview()//
            pok.concreteView!.frame = CGRect(x: margin_base * CGFloat(index), y: PPedMargin, width: MXSSize.Pw, height: MXSSize.Ph)
            self.addSubview(pok.concreteView!)
            pok.concreteView?.showWidth = MXSSize.Pw
        }
        
        var index = 0
        while index < pokers.count {
            let pok = pokers[index]
            let pokerView = MXSPokerView.init()
            pokerScrollView.addSubview(pokerView)
            pokerView.frame = CGRect.init(x: margin_base * CGFloat(index), y: PPedMargin, width: MXSSize.Pw, height: MXSSize.Ph)
            pokerView.controller = self
            pok.concreteView = pokerView
            pokerView.showWidth = margin_count
            graspPokerViewes.append(pokerView)
            index += 1
        }
        graspPokerViewes.last?.showWidth = MXSSize.Pw
        
        
        for pok in graspPokeres {
            if pok.concreteView == nil {
                pok.concreteView = MXSPokerView.init()
            }
            pok.concreteView!.removeFromSuperview()
            pok.concreteView!.frame = CGRect(x: self.frame.width-MXSSize.Pw, y: 0, width: MXSSize.Pw, height: MXSSize.Ph)
            self.addSubview(pok.concreteView!)
            pok.concreteView?.showWidth = MXSSize.Pw
            passPokeres.append(pok)
        }
        
        let sum_width = MXSSize.Pw * CGFloat(passPokeres.count)
        var org_x: CGFloat = 0.0
        if sum_width <= self.frame.width {
            org_x = (self.frame.width - sum_width) * 0.5 }
        else {
            org_x = self.frame.width - sum_width }
        
        for index in 0..<passPokeres.count {
            let pok = passPokeres[index]
            UIView.animate(withDuration: 0.15) {
                pok.concreteView!.frame = CGRect.init(x: org_x + MXSSize.Pw * CGFloat(index), y: 0, width: MXSSize.Pw, height: MXSSize.Ph)
            }
        }
        
    }
    
}
