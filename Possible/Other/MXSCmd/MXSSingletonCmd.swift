//
//  MXSSingletonCmd.swift
//  MXSSwift
//
//  Created by Sunfei on 2018/6/4.
//  Copyright © 2018年 MXS. All rights reserved.
//

import UIKit

class MXSSingletonCmd: NSObject {

    static let shared = MXSSingletonCmd()
    
    lazy var FileImageNams : Array<String> = {
        var names = Array<String>.init()
        
        return names
    }()
    
    lazy var DataFileCmd : MXSDataFileCmd = {
        var cmd = MXSDataFileCmd.init()
        
        return cmd
    }()
}
