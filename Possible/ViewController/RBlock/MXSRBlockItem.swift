//
//  MXSRBlockItem.swift
//  Possible
//
//  Created by Sunfei on 2024/4/9.
//  Copyright © 2024 boyuan. All rights reserved.
//

import Foundation
import UIKit

class MXSRBlockItem {
    
    enum RBlockItem : Int {
        case unknown = 0
        case single = 1
        case double = 2
        case tee = 3
        case armLeft = 4
        case armRight = 5
        case footLeft = 6
        case footRight = 7
    }
    
    enum RBlockItemForm : Int {
        case portrait = 0
        case landscapeLeft = 1
        case upsideDown = 2
        case landscapeRight = 3
    }
    
    var item: RBlockItem = .unknown
    var coordinate = (0, 0)
    var unitSet: [(Int, Int)] = [(0, 0)]
    var form: RBlockItemForm = .portrait
    
    
    convenience init(item: RBlockItem) {
        self.init()
        self.item = item
        switch item {
        case .unknown:
            unitSet = [(0, 0)]
        case .single:
            unitSet = [(0, 0), (0, 1), (0, 2), (0, 3)]
        case .double:
            unitSet = [(0, 0), (0, 1), (1, 0), (1, 1)]
        case .armLeft:
            unitSet = [(0, 0), (0, 1), (1, 0), (2, 0)]
        case .armRight:
            unitSet = [(0, 0), (0, 1), (1, 1), (2, 1)]
        case .footLeft:
            unitSet = [(0, 1), (1, 0), (1, 1), (2, 0)]
        case .footRight:
            unitSet = [(0, 0), (1, 0), (1, 1), (2, 1)]
        case .tee:
            unitSet = [(0, 1), (1, 0), (1, 1), (1, 2)]
        }
    }
    
    
    func transform() {
        switch form {
        case .portrait:
            form = .landscapeLeft
        case .landscapeLeft:
            form = .upsideDown
        case .upsideDown:
            form = .landscapeRight
        case .landscapeRight:
            form = .portrait
        }
    }
    
    func move(_ direction: MoveDirection) {
        
        switch direction {
        case .top:
            coordinate.0 = coordinate.0 - 1
        case .left:
            coordinate.1 = coordinate.1 - 1
        case .down:
            coordinate.0 = coordinate.0 + 1
        case .right:
            coordinate.1 = coordinate.1 + 1
        }
    }
    
}
