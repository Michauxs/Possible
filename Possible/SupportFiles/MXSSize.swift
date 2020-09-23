//
//  MXSSize.swift
//  Possible
//
//  Created by Sunfei on 2020/8/19.
//  Copyright © 2020 boyuan. All rights reserved.
//

//import Foundation
import UIKit

public class MXSSize {
    
    static let ScreenSize = UIScreen.main.bounds.size
    
    
    static let Sw:CGFloat = ScreenSize.width
    static let Sh:CGFloat = ScreenSize.height
    
    
    static let Hh:CGFloat = {
        return ScreenSize.height * 0.31
    }()
    static let Hw:CGFloat = Hh * 0.7
    
    
    static let Ph:CGFloat = Hh * 0.75
    static let Pw:CGFloat = Hw * 0.75
    
    static let PTextVerLimit:CGFloat = Pw * 0.4
    
    
    
}
