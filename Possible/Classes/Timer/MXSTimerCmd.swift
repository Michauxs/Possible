//
//  MXSTimerCmd.swift
//  Possible
//
//  Created by Sunfei on 2024/5/22.
//  Copyright © 2024 boyuan. All rights reserved.
//

import Foundation
import QuartzCore


class MXSTimerCmd {
    
    static let cmd : MXSTimerCmd = {
        let single = MXSTimerCmd.init()
        
//        NSTimeInterval period = 1.0; // 时间间隔
//        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//        dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
//        dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0);
//        dispatch_source_set_event_handler(_timer, ^{
//            //在这里执行事件
//        });
//        dispatch_resume(_timer);  // 启动
        
        
        return single
    }()
    
    var monitors:[MXSWeakNote] = [MXSWeakNote]()
    
    lazy var cadlink: CADisplayLink = {
        let dlick = CADisplayLink(target: self, selector: #selector(self.handleDisplayLink))
        dlick.add(to: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        return dlick
    }()
    
//    lazy var timer: Timer = {
//        let tim = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { tm in
//            self.timerRun()
//        })
//        return tim
//    }()
    
    var sec = 0
    @objc func handleDisplayLink() {
        sec += 1
        if sec == 30 {
            timerRun()
            sec = 0
        }
    }
    
    func timerRun() {
        
        var has_note = false
        for note in monitors {
            if let vc = note.vc {
                MXSLog(vc, "Timer.note.vc")
                vc.timerCmdRunAction()
//                let func1 = vc.MXSFuncMapCmd.functionVoid1
//                func1!()
//                vc.MXSFuncMapCmd.callFunction(byName: "timerCmdRunAction")
//                (MXSRBlockController*)vc.run
                has_note = true
            }
        }
        
        if has_note == false {
            monitors.removeAll()
            self.cadlink.isPaused = true
//            self.timer.fireDate = Date.distantFuture
        }
    }
    
    func monitor(_ vc: MXSViewController) {
        let note = MXSWeakNote(vc: vc)
        monitors.append(note)
        
        monitors.removeAll { note in
            note.vc == nil
        }
        
//        textVC = vc
//        self.timer.fireDate = Date.distantPast
        self.cadlink.isPaused = false
    }
    func unMonitor(_ vc: MXSViewController) {
        monitors.removeAll { one in
            one.vc == vc
        }
        if monitors.count == 0 {
            self.cadlink.isPaused = true
        }
    }
}


class MXSWeakNote {
    
    weak var vc: MXSViewController?
    
    init(vc: MXSViewController? = nil) {
        self.vc = vc
    }
    
}
