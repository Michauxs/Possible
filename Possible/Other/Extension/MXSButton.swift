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
        if fontSize>1000.0 {font = UIFont.init(name: FontKaiTiBold, size: fontSize-1000)!}
        else if fontSize>900.0 {font = UIFont.init(name: FontXingKai, size: fontSize-900)!}
        else if fontSize>600.0 {font = UIFont.systemFont(ofSize: fontSize-600.0, weight: .bold)}
        else if fontSize>300.0 {font = UIFont.systemFont(ofSize: fontSize-300.0, weight: .regular)}
        else {font = UIFont.systemFont(ofSize: fontSize, weight: .light)}
        self.titleLabel?.font = font
    }
    
    convenience init(_ text:String, fontSize:CGFloat, textColor:UIColor, backgColor:UIColor) {
        self.init()
        self.setTitle(text, for: .normal)
        self.setTitleColor(textColor, for: .normal)
        
        var font: UIFont = UIFont.systemFont(ofSize: 14)
        if fontSize>1000.0 {font = UIFont.init(name: FontKaiTiBold, size: fontSize-1000)!}
        else if fontSize>900.0 {font = UIFont.init(name: FontXingKai, size: fontSize-900)!}
        else if fontSize>600.0 {font = UIFont.systemFont(ofSize: fontSize-600.0, weight: .bold)}
        else if fontSize>300.0 {font = UIFont.systemFont(ofSize: fontSize-300.0, weight: .regular)}
        else {font = UIFont.systemFont(ofSize: fontSize, weight: .light)}
        self.titleLabel?.font = font
        
        self.backgroundColor = backgColor
    }

}
