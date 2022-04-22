//
//  MXSPokerCmd.swift
//  Possible
//
//  Created by Sunfei on 2020/8/20.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit
import Foundation

class MXSPoker : NSObject {
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
        colorGuise = c
        let a = attri[3] as! PokerAction
        actionFate = a
        actionGuise = a
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
    var isPicked: Bool = false {
        didSet {
            concreteView?.isUp = isPicked
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
        let action:Array<PokerAction> = [.duel, .remedy, .attack, .attack, .attack, .defense, .defense, .defense, .steal, .steal, .destroy, .remedy, .detect,
                                         .duel, .warFire, .warFire, .arrowes, .arrowes, .attack, .attack, .defense, .steal, .steal, .destroy, .remedy, .detect]
        
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
        for idx in 0..<count {
            if pokers_ready!.isEmpty {
                if !shuffle() { //丧尽天良刷牌机
                    return tmp
                }
            }
            let last = pokers_ready!.removeLast()
            MXSLog(last, "poker_"+"\(idx)")
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
    func someoneFromUid(_ uid:Int) -> MXSPoker? {
        if let index = pokers.firstIndex(where: { (poker) -> Bool in poker.uid == uid }) {
            let p = pokers[index]
            return p
        }
        return nil
    }
    func getPokersFromUids(_ poker_uid_arr: Array<Int>) -> Array<MXSPoker> {
//        if let index = pokers.firstIndex(where: { (poker) -> Bool in poker.uid == uid }) {
//            let p = pokers[index]
//            return p
//        }
//        return nil
        
        var poker_arr:Array<MXSPoker> = Array<MXSPoker>()
        for uid in poker_uid_arr {
            if let p = MXSPokerCmd.shared.someoneFromUid(uid) {
                poker_arr.append(p)
            }
        }
        return poker_arr
    }
}

