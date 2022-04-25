//
//  MXSButton.swift
//  Possible
//
//  Created by Sunfei on 2020/9/4.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit

public extension UIButton {
    
    convenience init(_ text:String, fontSize:CGFloat, textColor:UIColor) {
        self.init()
        self.setTitle(text, for: .normal)
        self.setTitleColor(textColor, for: .normal)
        
        var font: UIFont = UIFont.systemFont(ofSize: 14)
        if fontSize>1000.0 && fontSize<1200 {font = UIFont.init(name: FontKaiTiBold, size: fontSize-1000)!}
        if fontSize>900.0 && fontSize<1000 {font = UIFont.init(name: FontXingKai, size: fontSize-900)!}
        if fontSize>600.0 && fontSize<900 {font = UIFont.systemFont(ofSize: fontSize-600.0, weight: .bold)}
        if fontSize>300.0 && fontSize<600 {font = UIFont.systemFont(ofSize: fontSize-300.0, weight: .regular)}
        if fontSize<300.0 {font = UIFont.systemFont(ofSize: fontSize-300.0, weight: .light)}
        self.titleLabel?.font = font
    }
    
    convenience init(_ text:String, fontSize:CGFloat, textColor:UIColor, backgColor:UIColor) {
        self.init()
        self.setTitle(text, for: .normal)
        self.setTitleColor(textColor, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        self.backgroundColor = backgColor
    }

}
