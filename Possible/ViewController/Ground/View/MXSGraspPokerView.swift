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
        super.init(frame: frame)
        self.controller = controller
        self.frame = frame
        self.showsHorizontalScrollIndicator = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func appendPoker(pokers:Array<MXSPoker>) {
        graspPokeres.append(contentsOf: pokers)
        
        layoutPokerView()
    }
    
    public func removePoker(pokers:Array<MXSPoker>) {
        if pokers.count < 1 { return }
        
        for poker in pokers {
            graspPokeres.removeAll(where: {$0 === poker})
        }
        
        layoutPokerView()
    }
    
    func layoutPokerView() {
        let count = graspPokeres.count
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
        
        for index in 0..<graspPokeres.count {
            let pok = graspPokeres[index]
            if pok.concreteView == nil {
                pok.concreteView = MXSPokerView.init() }
            else { pok.concreteView!.removeFromSuperview() }//
            pok.concreteView!.controller = self.controller
            UIView.animate(withDuration: 0.25) {
                pok.concreteView!.frame = CGRect(x: margin_base * CGFloat(index), y: self.PPedMargin, width: MXSSize.Pw, height: MXSSize.Ph) }
            self.addSubview(pok.concreteView!)
            pok.concreteView?.showWidth = pok === graspPokeres.last ? MXSSize.Pw : margin_base
        }
    }
    
    
    
}
