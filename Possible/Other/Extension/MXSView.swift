//
//  MXSView.swift
//  Possible
//
//  Created by Sunfei on 2020/9/8.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit

public extension UIView {

    func setRaius(_ radius:CGFloat, borderColor:UIColor, borderWitdh:CGFloat) {
        self.clipsToBounds = true
        
        self.layer.cornerRadius = radius
        self.layer.borderWidth = borderWitdh
        self.layer.borderColor = borderColor.cgColor
    }
    
    
    

}
