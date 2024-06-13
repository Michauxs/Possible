//
//  MXSPassedView.swift
//  Possible
//
//  Created by Sunfei on 2020/9/7.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit

class MXSPassedView: MXSBaseView {

    var PokerArray: Array<MXSPoker> = Array<MXSPoker>()
    var offset_x: CGFloat = 0.0
    
    func readyOffsetX () {
        offset_x = (self.frame.width - MXSSize.Pw) * 0.5
    }
    
    override func setupSubviews() {
        self.clipsToBounds = true
        //self.clearPokersView()
    }
    public func clearPokersView() {
        self.readyOffsetX()
        for pokere in PokerArray {
            pokere.concreteView!.removeFromSuperview()
        }
        PokerArray.removeAll()
    }
    
    typealias CollectFinishBlock = () -> Void
    public func depositPokerFromDeck( _ pokers:[MXSPoker], finish: @escaping CollectFinishBlock) {
        if pokers.count == 0 { return }
        
        var points = [CGPoint]()
        for poker in pokers {
            if poker.concreteView == nil {
                poker.concreteView = MXSPokerView.init()
            }
            points.append(CGPoint(x: MXSSize.Sw - 20, y: 20))
        }
        
        self.depositPoker(pokers, points: points, reverse: true) {
            finish()
        }
    }
    public func depositPoker( _ pokers:[MXSPoker], fromHero hero: MXSHero, finish: @escaping CollectFinishBlock) {
        if pokers.count == 0 { return }
        var points = [CGPoint]()
        var reve = true
        if let graspView = hero.GraspView {
            reve = false
            for poker in pokers {
                let concreteView = poker.concreteView!
                let frame_for_vc = graspView.convert(concreteView.frame, to: self.control!.view)
                points.append(CGPoint(x: frame_for_vc.midX, y: frame_for_vc.midY))
            }
        }
        else {
            for poker in pokers {
                if poker.concreteView == nil {
                    poker.concreteView = MXSPokerView.init()
                }
                let frame_for_vc = hero.concreteView!.frame
                points.append(CGPoint(x: frame_for_vc.midX, y: frame_for_vc.midY))
            }
        }
        
        self.depositPoker(pokers, points: points, reverse: reve) {
            finish()
        }
    }
    //reserve
    private func depositPoker( _ pokers:[MXSPoker], points: [CGPoint], reverse: Bool, finish: @escaping CollectFinishBlock) {
        
        for index in 0..<pokers.count {
            let poker = pokers[index]
            let point = points[index]
            poker.concreteView!.removeFromSuperview()
            
            self.control!.view.addSubview(poker.concreteView!)
            poker.concreteView!.frame = CGRect(x: point.x - MXSSize.Pw*0.5, y: point.y - MXSSize.Ph*0.5, width: MXSSize.Pw, height: MXSSize.Ph)
        }
        
        //let sum = PokerArray.count+pokers.count
        PokerArray.append(contentsOf: pokers)
        
        let sum_width = MXSSize.Pw * CGFloat(PokerArray.count)
        var org_x: CGFloat = 0.0
        if sum_width <= self.frame.width {
            org_x = (self.frame.width - sum_width) * 0.5
        }
        else {
            org_x = self.frame.width - sum_width
        }
        
        var frameArray = [CGRect]()
        var frameArray_for_vc = [CGRect]()
        for index in 0..<PokerArray.count {
            let poker = PokerArray[index]
            let frame = CGRect(x: org_x + MXSSize.Pw*CGFloat(index), y: 0, width: MXSSize.Pw, height: MXSSize.Ph)
            frameArray.append(frame)
            
            if index < PokerArray.count - pokers.count {
                UIView.animate(withDuration: 0.5) {
                    poker.concreteView!.frame = frame
                }
            }
            else {
                let frame_conv = self.convert(frame, to: self.control!.view)
                frameArray_for_vc.append(frame_conv)
                UIView.animate(withDuration: 0.5) {
                    poker.concreteView!.frame = frame_conv
                } completion: { finished in
                    poker.concreteView!.removeFromSuperview()
                    self.addSubview(poker.concreteView!)
                    poker.concreteView!.frame = frame
                }

            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            finish()
        }
    }
    
    public func fadeout () {
        for pok in PokerArray {
            UIView.animate(withDuration: 0.5, animations: {
                pok.concreteView!.alpha = 0
                pok.concreteView!.frame = CGRect.init(x: -MXSSize.Pw, y: 0, width: MXSSize.Pw, height: MXSSize.Ph)// <-
            }) { (success) in
                pok.concreteView?.removeFromSuperview()
                pok.concreteView = nil
            }
        }
        PokerArray.removeAll()
    }
    
    
}
