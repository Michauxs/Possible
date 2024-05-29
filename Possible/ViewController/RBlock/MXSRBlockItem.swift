//
//  MXSRBlockItem.swift
//  Possible
//
//  Created by Sunfei on 2024/4/9.
//  Copyright © 2024 boyuan. All rights reserved.
//

import Foundation
import UIKit

let RBlockItemFormEnumCount: Int = 4


enum RBlockItemForm : Int {
    case portrait = 0
    case landscapeLeft = 1
    case upsideDown = 2
    case landscapeRight = 3
}

class MXSRBlockItem {
    
    class func copyBlockItem(_ block: MXSRBlockItem) -> MXSRBlockItem {
        let rb = MXSRBlockItem(item: block.item)
        rb.coordinate = block.coordinate
        rb.form = block.form
        return rb
    }
    
    enum RBlockType : Int {
        case unknown = 0
        case single = 1
        case double = 2
        case tee = 3
        case armLeft = 4
        case armRight = 5
        case footLeft = 6
        case footRight = 7
    }
    
    
    /**(row, col)**/
    var coordinateSet: [(Int, Int)] = [(0, 0)]
    
    var unitSet: [(Int, Int)] = [(0, 0)] {
        didSet {
            for index in 0..<unitSet.count {
                coordinateSet[index].0 = coordinate.0 + unitSet[index].0
                coordinateSet[index].1 = coordinate.1 + unitSet[index].1
            }
            MXSLog(coordinateSet, "coordinateSet")
        }
    }
    var coordinate = (0, 0) {
        didSet {
            for index in 0..<unitSet.count {
                coordinateSet[index].0 = coordinate.0 + unitSet[index].0
                coordinateSet[index].1 = coordinate.1 + unitSet[index].1
            }
            MXSLog(coordinateSet, "coordinateSet")
        }
    }
    
    
    
    class func randomRBlock() -> MXSRBlockItem {
        if let type = RBlockType.init(rawValue: Int.random(in: 1...7)) {
            return MXSRBlockItem(item: type)
        }
        return MXSRBlockItem(item: .double)
    }
    
    var item: RBlockType = .unknown
    convenience init(item: RBlockType) {
        self.init()
        self.item = item
        
        coordinateSet = [(0, 0), (0, 0), (0, 0), (0, 0)]
        
        switch item {
        case .unknown:
            unitSet = [(0, 0)]
        case .single:
            unitSet = [(0, 0), (0, 1), (0, 2), (0, 3)]
        case .double:
            unitSet = [(0, 0), (0, 1), (1, 0), (1, 1)]
        case .armLeft:
            unitSet = [(0, 0), (0, 1), (1, 1), (2, 1)]
        case .armRight:
            unitSet = [(0, 0), (0, 1), (1, 0), (2, 0)]
        case .footLeft:
            unitSet = [(0, 0), (1, 0), (1, 1), (2, 1)]
        case .footRight:
            unitSet = [(0, 1), (1, 0), (1, 1), (2, 0)]
        case .tee:
            unitSet = [(0, 1), (1, 0), (1, 1), (1, 2)]
        }
    }
    
    
    var form: RBlockItemForm = .portrait {
        didSet {
            switch self.item {
            case .unknown:
                unitSet = [(0, 0)]
            case .single:
                switch form {
                case .portrait, .upsideDown:
                    unitSet = [(0, 0), (0, 1), (0, 2), (0, 3)]
                case .landscapeLeft, .landscapeRight:
                    unitSet = [(0, 0), (1, 0), (2, 0), (3, 0)]
                }
            case .double:
                break
            case .armLeft:
                switch form {
                case .portrait:
                    unitSet = [(0, 0), (0, 1), (1, 1), (2, 1)]
                case .landscapeLeft:
                    unitSet = [(0, 0), (0, 1), (0, 2), (1, 0)]
                case .upsideDown:
                    unitSet = [(0, 0), (1, 0), (2, 0), (2, 1)]
                case .landscapeRight:
                    unitSet = [(1, 0), (1, 1), (1, 2), (0, 2)]
                }
            case .armRight:
                switch form {
                case .portrait:
                    unitSet = [(0, 0), (0, 1), (1, 0), (2, 0)]
                case .landscapeLeft:
                    unitSet = [(0, 0), (1, 0), (1, 1), (1, 2)]
                case .upsideDown:
                    unitSet = [(2, 0), (0, 1), (1, 1), (2, 1)]
                case .landscapeRight:
                    unitSet = [(0, 0), (0, 1), (0, 2), (1, 2)]
                }
            case .footLeft:
                switch form {
                case .portrait, .upsideDown:
                    unitSet = [(0, 0), (1, 0), (1, 1), (2, 1)]
                case .landscapeLeft, .landscapeRight:
                    unitSet = [(0, 1), (0, 2), (1, 0), (1, 1)]
                }
            case .footRight:
                switch form {
                case .portrait, .upsideDown:
                    unitSet = [(0, 1), (1, 0), (1, 1), (2, 0)]
                case .landscapeLeft, .landscapeRight:
                    unitSet = [(0, 0), (0, 1), (1, 1), (1, 2)]
                }
            case .tee:
                switch form {
                case .portrait:
                    unitSet = [(0, 1), (1, 0), (1, 1), (1, 2)]
                case .landscapeLeft:
                    unitSet = [(0, 1), (1, 0), (1, 1), (2, 1)]
                case .upsideDown:
                    unitSet = [(0, 0), (0, 1), (0, 2), (1, 1)]
                case .landscapeRight:
                    unitSet = [(0, 0), (1, 0), (1, 1), (2, 0)]
                }
            }
        }
    }
    
    func transform() {
//        switch form {
//        case .portrait:
//            form = .landscapeLeft
//        case .landscapeLeft:
//            form = .upsideDown
//        case .upsideDown:
//            form = .landscapeRight
//        case .landscapeRight:
//            form = .portrait
//        }
        
        self.form = RBlockItemForm(rawValue: (self.form.rawValue + 1) % RBlockItemFormEnumCount)!
    }
    
    func move(_ direction: MoveDirection) {
        var coor = coordinate
        switch direction {
        case .top:
            coor.0 = coordinate.0 - 1
        case .left:
            coor.1 = coordinate.1 - 1
        case .down:
            coor.0 = coordinate.0 + 1
        case .right:
            coor.1 = coordinate.1 + 1
        }
        
        self.coordinate = coor
        
    }
    
}
