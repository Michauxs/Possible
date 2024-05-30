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
        return single
        
//        NSTimeInterval period = 1.0; // 时间间隔
//        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//        dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
//        dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0);
//        dispatch_source_set_event_handler(_timer, ^{
//            //在这里执行事件
//        });
//        dispatch_resume(_timer);  // 启动
        
    }()
     
    /**
     class func makeTimerSource(flags: DispatchSource.TimerFlags = [], queue: DispatchQueue? = nil) -> DispatchSourceTimer
     // 默认在主队列中调度使用
     let timer = DispatchSource.makeTimerSource()
     // 指定在主队列中调度使用
     let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
     // 指定在全局队列中调度使用
     let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
     // 指定在自定义队列中调度使用
     let customQueue = DispatchQueue(label: "customQueue")
     let timer = DispatchSource.makeTimerSource(flags: [], queue: customQueue)
     
     // 从现在开始，每秒执行一次。
     timer?.schedule(deadline: DispatchTime.now(), repeating: .seconds(1), leeway: .nanoseconds(1))
     // 5秒之后执行任务，不重复。
     timer?.schedule(deadline: DispatchTime.now() + 5, repeating: .never, leeway: .nanoseconds(1))
     
     var timer: DispatchSourceTimer?

     func initTimer() {
         // 默认在主队列中调度使用
         timer = DispatchSource.makeTimerSource()
         
         // 从现在开始，每秒执行一次。
         timer?.schedule(deadline: DispatchTime.now(), repeating: .seconds(1), leeway: .nanoseconds(1))
         // 5秒之后执行任务，不重复。
         timer?.setEventHandler {
             DispatchQueue.main.async {
             print("执行任务")
         }
     }
     
     timer?.setRegistrationHandler(handler: {
         DispatchQueue.main.async {
             print("Timer开始工作了")
             }
         })
         timer?.activate()
     }
     
     Timer的一下控制方法及状态：
     activate() : 当创建完一个Timer之后，其处于未激活的状态，所以要执行Timer，需要调用该方法。
     suspend() : 当Timer开始运行后，调用该方法便会将Timer挂起，即暂停。
     resume() : 当Timer被挂起后，调用该方法便会将Timer继续运行。
     cancel() : 调用该方法后，Timer将会被取消，被取消的Timer如果想再执行任务，则需要重新创建。
     上面的这些方法如果使用不当，很容易造成APP崩溃，下面来看一下具体注意事项及建议：

     当Timer创建完后，建议调用activate()方法开始运行。如果直接调用resume()也可以开始运行。
     suspend()的时候，并不会停止当前正在执行的event事件，而是会停止下一次event事件。
     当Timer处于suspend的状态时，如果销毁Timer或其所属的控制器，会导致APP奔溃。
     2020-11-28 02:20:00 +0000 Timer开始工作了
     2020-11-28 02:20:00 +0000 执行任务
     2020-11-28 02:20:01 +0000 执行任务
     2020-11-28 02:20:02 +0000 执行任务
     suspend()和resume()需要成对出现，挂起一次，恢复一次，如果Timer开始运行后，在没有suspend的时候，直接调用resume()，会导致APP崩溃。
     使用cancel()的时候，如果Timer处于suspend状态，APP崩溃。
     另外需要注意block的循环引用问题。
     
     */
    
    
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
//                MXSLog(vc, "Timer.note.vc")
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
