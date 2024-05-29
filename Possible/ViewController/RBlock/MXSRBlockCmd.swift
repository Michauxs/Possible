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
                
        for row in 0..<Sum_row {
            for col in 0..<Sum_col {
                let unit = RBlockUnitFillNote(isFill: false, count: 0)
                filledTable[row*100+col] = unit
            }
        }
    }
    
    var filledTable = [Int:RBlockUnitFillNote]()
    class RBlockUnitFillNote {
        var isFill: Bool = false
        var count: Int = 0
        
        init(isFill: Bool, count: Int) {
            self.isFill = isFill
            self.count = count
        }
    }
    func fillUnit(_ idx: Int, fill: Bool = true) {
        if let unit = filledTable[idx] {
            unit.count = unit.count + (fill ? 1 : -1)
//            if unit.count < 0 { unit.count = 0 }
            unit.isFill = unit.count > 0
        }
    }
    
    func fillRBlock(_ holder: MXSRBlockItem, fill: Bool = true) {
        for coor in holder.coordinateSet { fillUnit(coor.0*100+coor.1, fill: fill) }
    }
    func clearAllFilled() {
        for unit in Array(filledTable.values) {
            unit.count = 0
            unit.isFill = false
        }
    }
    
    
    func checkRBlockTouchingTop(_ block: MXSRBlockItem) -> Bool {
        for index in 0..<block.coordinateSet.count {
            let coor = block.coordinateSet[index]
            if let unit = filledTable[coor.0*100 + coor.1] {
                if unit.count > 1 {
                    return true
                }
            }
        }
        return false
    }
    
    
    enum SupposResult {
        case driftdown
        case settledown
        case barrier
    }
    func supposingRBlockMove(RBlock block: MXSRBlockItem, move: MoveDirection, judge: (_ direction: MoveDirection ,_ result: SupposResult) -> Void) {
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
        }
        
        for index in 0..<block.unitSet.count {
            let unit = block.unitSet[index]
            let row = coor.0 + unit.0
            let col = coor.1 + unit.1
            
            let cont = block.coordinateSet.filter { (a, b) in a == row && b == col }
            if cont.count > 0 { continue } //unit将移动到正在占用的block
            
            if row < 0 || row >= Sum_row || col < 0 || col >= Sum_col {//越界
                switch move {
                case .top:
                    break
                case .left, .right://障碍
                    judge(move, .barrier)
                case .down://定格
                    judge(move, .settledown)
                }
                return
            }
            
            if filledTable[row*100+col]?.isFill == true { //障碍/定格
                switch move {
                case .top:
                    break
                case .left, .right://障碍
                    judge(move, .barrier)
                case .down://定格
                    judge(move, .settledown)
                }
                return
            }
        }//for end
        
        judge(move, .driftdown)
    }
    
    
    func checkRow() -> [Int] {
        var rowArray = [Int]()
        
        for row in 0..<Sum_row {
            
            var count_col: Int = 0
            for col in 0..<Sum_col {
                if filledTable[row*100+col]?.isFill == true { count_col += 1 }
            }
            
            if count_col == Sum_col { rowArray.append(row) }
            
            count_col = 0
        }
        return rowArray
    }
    
    
    func emptyRow(_ array: [Int]) {
        for index in 0..<array.count {
            let row = array[index]
            MXSLog("Clearing at row: " + "\(row)")
            for col in 0..<Sum_col {
                filledTable[row*100+col]?.isFill = false
            }
            
            //在一次循环内，前面清空一行后，后面跟着把上方的block下压
            for row_index in 0...row {
                //清空行时，row从大到小或从小到大都可以，下压时要从大到小row
                let row_revorder = row - row_index
                MXSLog("Line at row: " + "\(row_revorder)")
                if row_revorder == 0 {//第1行清空了，没有需要下压的行
                    MXSLog("not need")
                    
                }
                else {
                    MXSLog("Pressing at row: " + "\(row_revorder)")
                    for col in 0..<Sum_col {
                        if filledTable[(row_revorder-1)*100+col]?.isFill == true {
                            fillUnit(row_revorder*100+col)
                            fillUnit((row_revorder-1)*100+col, fill: false)
                        }
                    }
                }
            }
        }
        
        MXSLog("Empty Done")
    }
    
    
    func supposingRBlockTransform(RBlock block: MXSRBlockItem) -> Bool {
        
        //let form_new = RBlockItemForm(rawValue: (block.form.rawValue + 1) % RBlockItemFormEnumCount)
        
        fillRBlock(block, fill: false)
        
        
        let item = MXSRBlockItem.copyBlockItem(block)
        item.transform()
        
        fillRBlock(item)
        
        for index in 0..<item.coordinateSet.count {
            let coor = item.coordinateSet[index]
            let row = coor.0
            let col = coor.1
            if row < 0 || row >= Sum_row || col < 0 || col >= Sum_col {//越界
                fillRBlock(block)
                fillRBlock(item, fill: false)
                return false
            }
            
            if let unit = filledTable[coor.0*100 + coor.1] {
                if unit.count > 1 {
                    fillRBlock(block)
                    fillRBlock(item, fill: false)
                    return false
                }
            }
            
        }//for end
        fillRBlock(block)
        fillRBlock(item, fill: false)
        return true
    }
    
    
}
