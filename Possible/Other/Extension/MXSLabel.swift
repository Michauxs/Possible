//
//  MXSLabel.swift
//  Possible
//
//  Created by Sunfei on 2020/9/4.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit

public extension UILabel {

    convenience init(text:String = "", fontSize:CGFloat = 314.0, textColor:UIColor = .clear, align:NSTextAlignment = .left) {
        self.init()
        self.text = text
        self.textColor = textColor
        if fontSize>600.0 {self.font = UIFont.systemFont(ofSize: fontSize-600.0, weight: .bold)}
        if fontSize>300.0 && fontSize<600 {self.font = UIFont.systemFont(ofSize: fontSize-300.0, weight: .regular)}
        if fontSize<300.0 {self.font = UIFont.systemFont(ofSize: fontSize-300.0, weight: .light)}
        self.textAlignment = align
    }

}
