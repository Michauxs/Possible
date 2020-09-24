//
//  MXSPassedView.swift
//  Possible
//
//  Created by Sunfei on 2020/9/7.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit

class MXSPassedView: MXSBaseView {

    var passPokeres: Array<MXSPoker> = Array<MXSPoker>()
    var offset_x: CGFloat = 0.0
    var willCollect:Bool = true
    
    func readyOffsetX () {
        offset_x = (self.frame.width - MXSSize.Pw) * 0.5
    }
    
    override func setupSubviews() {
        self.clipsToBounds = true
    }
    
    public func collectPoker(pokers:Array<MXSPoker>) {
        if pokers.count == 0 { return }
        
        /**计算已有pok*/
        if passPokeres.count == 0 { offset_x = (self.frame.width - MXSSize.Pw) * 0.5 }
        else { offset_x = (self.frame.width + MXSSize.Pw * CGFloat(passPokeres.count)) * 0.5 }
        
//        let poker_view = passPokeres.first!
//        UIView.animate(withDuration: 0.15, animations: {
//            poker_view.frame = CGRect.init(x: self.frame.minX + self.offset_x, y: self.frame.minY, width: MXSSize.PokerWidth, height: MXSSize.PokerHeight)
//        }) { (success) in
//            poker_view.removeFromSuperview()
//            poker_view.frame = CGRect.init(x: self.offset_x, y: 0, width: MXSSize.PokerWidth, height: MXSSize.PokerHeight)
//            self.addSubview(poker_view)
//        }
        
//        passPokeres.append(contentsOf: pokers)
        for pok in pokers {
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
        if sum_width <= self.frame.width { org_x = (self.frame.width - sum_width) * 0.5 }
        else { org_x = self.frame.width - sum_width }
        
        for index in 0..<passPokeres.count {
            let pok = passPokeres[index]
            UIView.animate(withDuration: 0.15) {
                pok.concreteView!.frame = CGRect.init(x: org_x + MXSSize.Pw * CGFloat(index), y: 0, width: MXSSize.Pw, height: MXSSize.Ph)
            }
        }
        
    }
    
    public func fadeout () {
        for pok in passPokeres {
            UIView.animate(withDuration: 0.5, animations: {
                pok.concreteView!.alpha = 0
                pok.concreteView!.frame = CGRect.init(x: -MXSSize.Pw, y: 0, width: MXSSize.Pw, height: MXSSize.Ph)
            }) { (success) in
                pok.concreteView!.removeFromSuperview()
                pok.concreteView = nil
            }
        }
        passPokeres.removeAll()
    }
    
    
}
