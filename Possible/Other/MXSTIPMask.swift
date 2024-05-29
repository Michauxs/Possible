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
    
    public func showMaskWithTip(_ title:String, auto:Bool = true) {
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
        
        if let mask = maskLayer.last(where: { one in
            one.autoDispear == true
        }) {
//            mask?.isHidden = true
            mask.removeFromSuperview()
            maskLayer.removeLast()
        }
        
        
    }
    
}

class MXSTIPMask: MXSBaseView {

    let autoDispear: Bool = true
    
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
        
        let contentView = UIView.init()
        contentView.backgroundColor = .alphaBlack
        addSubview(contentView)
        contentView.snp.makeConstraints { (m) in
            m.center.equalToSuperview()
            m.size.equalTo(CGSize.init(width: 240, height: 80))
        }
        contentView.setRaius(2, borderColor: UIColor.gray, borderWitdh: 0)
        
        contentView.addSubview(titleLabel)
        titleLabel.numberOfLines = 0;
        titleLabel.textAlignment = .center
        titleLabel.snp.makeConstraints { (m) in
            m.centerY.equalToSuperview()
            m.left.equalToSuperview().offset(20)
            m.right.equalToSuperview().inset(20)
        }
    }
    
//    public func showMaskWithTip(title:String) {
//        titleLabel.text = title
//    }
//    public func dispearMaskTip(title:String) {
//        self.isHidden = true
//    }
    
}
