//
//  MXSBaseView.swift
//  Possible
//
//  Created by Sunfei on 2020/8/19.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit

class MXSBaseView: UIView {
    
//    convenience init() {
//        self.init()
////        setupSubviews()
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }

    open func setupSubviews() {
        
    }

}
