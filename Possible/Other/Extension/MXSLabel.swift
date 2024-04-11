//
//  MXSLabel.swift
//  Possible
//
//  Created by Sunfei on 2020/9/4.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit

public extension UILabel {

    /**000 300 600-900 为系统字体：细/正常/粗
     * 900-1000 楷体regular
     * 1000-1200 楷体bold
     */
    convenience init(text:String = "", fontSize:CGFloat = 314.0, textColor:UIColor = .clear, align:NSTextAlignment = .left) {
        self.init()
        self.text = text
        self.textColor = textColor
        
        if fontSize>1000.0 {self.font = UIFont.init(name: FontKaiTiBold, size: fontSize-1000)}
        else if fontSize>900.0 {self.font = UIFont.init(name: FontXingKai, size: fontSize-900)}
        else if fontSize>600.0 {self.font = UIFont.systemFont(ofSize: fontSize-600.0, weight: .bold)}
        else if fontSize>300.0 {self.font = UIFont.systemFont(ofSize: fontSize-300.0, weight: .regular)}
        else {self.font = UIFont.systemFont(ofSize: fontSize-300.0, weight: .light)}
        
        self.textAlignment = align
        self.numberOfLines = 0
    }

}
