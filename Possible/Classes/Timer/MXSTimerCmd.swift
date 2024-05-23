//
//  MXSTimerCmd.swift
//  Possible
//
//  Created by Sunfei on 2024/5/22.
//  Copyright © 2024 boyuan. All rights reserved.
//

import Foundation


class MXSTimerCmd {
    
    static let cmd : MXSTimerCmd = {
        let single = MXSTimerCmd.init()
        
        return single
    }()
    
    var monitors:[MXSWeakNote] = [MXSWeakNote]()
    
    lazy var timer: Timer = {
        
        let tim = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { tm in
            self.timerRun()
        })
        return tim
    }()
    
    func timerRun() {
        //once 0.5
        
        var has_note = false
        for note in monitors {
            if let vc = note.vc {
                vc.callFunction(byName: "timerCmdRunAction")
                has_note = true
            }
        }
        
        if has_note == false {
            self.timer.fireDate = Date.distantFuture
        }
    }
    
    func monitor(_ vc:MXSViewController) {
        let note = MXSWeakNote(vc: vc)
        monitors.append(note)
        
        self.timer.fireDate = Date.distantPast
    }
    
}

class MXSWeakNote {
    
    weak var vc: MXSViewController?
    
    init(vc: MXSViewController? = nil) {
        self.vc = vc
    }
}
