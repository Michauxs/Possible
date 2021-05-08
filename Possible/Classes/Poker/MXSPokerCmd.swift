//
//  MXSPokerCmd.swift
//  Possible
//
//  Created by Sunfei on 2020/8/20.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit

class MXSPoker {
    var uid: Int = 0
    var state: PokerState = .unknown
    var number: Int = 0
    var color: PokerColor = .unknown
    var colorGuise: PokerColor = .unknown
    var actionFate: PokerAction = .unknown
    var actionGuise: PokerAction = .unknown {
        didSet {
            self.concreteView?.actionGuiseLabel.isHidden = actionFate == actionGuise
            self.concreteView?.actionGuise = actionGuise
        }
    }
    
    var attribute: Array<Any>?
    
    /**[state number color text]*/
    init(_ attri:Array<Any>) {
        attribute = attri
        
        state = attri[0] as! PokerState
        let n = attri[1] as! Int
        number = n
        let c = attri[2] as! PokerColor
        color = c
        actionFate = attri[3] as! PokerAction
        actionGuise = actionFate
        uid = c.rawValue * 100 + n as Int
    }
    
    var concreteView: MXSPokerView? {
        didSet {
            concreteView?.belong = self
            
            concreteView?.numb = number
            concreteView?.color = color
            concreteView?.action = actionFate
        }
    }
    
}


class MXSPokerCmd {
    
    var pokers: Array<MXSPoker> = Array<MXSPoker>()
    var pokers_ready: Array<MXSPoker>?
    
    var priority: Array<PokerAction> = [.steal, .destroy, .warFire, .arrowes, .duel, .attack]
    
    
    static let shared : MXSPokerCmd = {
        let single = MXSPokerCmd.init()
        let color:Array<PokerColor> = [.heart, .spade, .club, .diamond]
        let action:Array<PokerAction> = [.duel, .recover, .attack, .attack, .attack, .defense, .defense, .defense, .steal, .steal, .destroy, .recover, .detect,
                                         .duel, .warFire, .warFire, .arrowes, .arrowes, .attack, .attack, .defense, .steal, .steal, .destroy, .recover, .detect]
        
        for index in 0..<13*2 {
            let index_trans = index%13
            for type in color {
                let pok = MXSPoker.init([PokerState.pass, index_trans+1, type, action[index]])
                single.pokers.append(pok)
            }
        }
        return single
    }()
    
    public func push(_ count: Int) -> Array<MXSPoker> {
        var tmp = Array<MXSPoker>()
        for _ in 0..<count {
            if pokers_ready!.isEmpty {
                if !shuffle() { //丧尽天良刷牌机
                    return tmp
                }
            }
            let last = pokers_ready!.removeLast()
            last.state = .handOn
            tmp.append(last)
        }
        return tmp
    }
    
    public func shuffle() -> Bool {
        var result = Array<MXSPoker>()
        for poker in pokers {
            if poker.state == PokerState.pass {
                poker.state = .ready
                result.append(poker)
            }
        }
        
        if result.count == 0 { return false }
        else {
            result.shuffle()
            pokers_ready = result
            return true
        }
    }
    
    func packagePoker(){
        for poker in pokers {
            poker.state = .pass
        }
    }
    
}

