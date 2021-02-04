//
//  MXSTIPMask.swift
//  Possible
//
//  Created by Sunfei on 2021/2/2.
//  Copyright © 2021 boyuan. All rights reserved.
//

import UIKit

class MXSTIPMaskCmd {
    
    var maskLayer:Array<MXSTIPMask> = Array<MXSTIPMask>()
    
    static let shared : MXSTIPMaskCmd = {
        let single = MXSTIPMaskCmd.init()
        return single
    }()
    
    public func showMaskWithTip(_ title:String, auto:Bool) {
        let mask = MXSTIPMask.init(frame: CGRect.init(x: 0, y: 0, width: MXSSize.Sw, height: MXSSize.Sh))
        mask.titleLabel.text = title
        
        UIApplication.shared.keyWindow?.addSubview(mask)
        maskLayer.append(mask)
        
        if auto {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.dispearMaskTip()
            }
        }
    }
        
    public func dispearMaskTip() {
        if maskLayer.count < 1 {
            return
        }
        let mask = maskLayer.last
        mask?.isHidden = true
        maskLayer.removeLast()
    }
    
}

class MXSTIPMask: MXSBaseView {

    lazy var titleLabel:UILabel = {
        return UILabel.init()
    }()
    
    override func setupSubviews() {
        let maskView = UIView.init()
        maskView.backgroundColor = .alphaBlack
        addSubview(maskView)
        maskView.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (m) in
            m.center.equalToSuperview()
        }
    }
    
//    public func showMaskWithTip(title:String) {
//        titleLabel.text = title
//    }
//    public func dispearMaskTip(title:String) {
//        self.isHidden = true
//    }
    
}
