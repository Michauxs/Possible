//
//  MXSRBlockCmd.swift
//  Possible
//
//  Created by Sunfei on 2024/4/24.
//  Copyright © 2024 boyuan. All rights reserved.
//

import Foundation

class MXSRBlockCmd {
    
    var Sum_row :Int = 0
    var Sum_col :Int = 0
    
    init(Sum_row: Int, Sum_col: Int) {
        self.Sum_row = Sum_row
        self.Sum_col = Sum_col
    }
    
    
    var filledTable = [Int:Bool]()
    func fillRBlock(_ holder: MXSRBlockItem, fill: Bool = true) {
        for coor in holder.coordinateSet { filledTable[coor.0*100+coor.1] = fill }
    }
    func clearAllFilled() {
        for key in Array(filledTable.keys) {
            filledTable[key] = false
        }
    }
    
    enum SupposResult {
        case driftdown
        case settledown
        case barrier
        case shutdown
    }
    func supposingRBlockMove(RBlock block: MXSRBlockItem, move: MoveDirection, judge: (_ direction: MoveDirection ,_ result: SupposResult) -> Void) -> Bool {
        
        fillRBlock(block, fill: false)
        
        var coor = block.coordinate
        switch move {
        case .top:
            coor.0 = block.coordinate.0 - 1
        case .left:
            coor.1 = block.coordinate.1 - 1
        case .down:
            coor.0 = block.coordinate.0 + 1
        case .right:
            coor.1 = block.coordinate.1 + 1
        case .stay:
            break
        }
        
        for index in 0..<block.unitSet.count {
            let unit = block.unitSet[index]
            let row = coor.0 + unit.0
            let col = coor.1 + unit.1
                
            if move != .stay {//
                let cont = block.coordinateSet.filter { (a, b) in a == row && b == col }
                if cont.count > 0 { continue } //unit将移动到正在占用的block
            }
            
            if row < 0 || row >= Sum_row || col < 0 || col >= Sum_col {//越界
                judge(move, .settledown)
                fillRBlock(block)
                return false
            }
            
            if filledTable[row*100+col] == true { //障碍/定格
                switch move {
                case .top:
                    break
                case .left, .right://障碍
                    judge(move, .barrier)
                case .down://定格
                    judge(move, .settledown)
                case .stay://顶格
//                    if coor.0 == 0 {  }
                    judge(move, .shutdown)
                }
                fillRBlock(block)
                return false
            }
        }//for end
        
        judge(move, .driftdown)
        return true
    }
    
}
