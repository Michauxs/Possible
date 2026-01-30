//
//  MXSPuddleCmd.swift
//  Possible
//
//  Created by Sunfei on 2026/1/16.
//  Copyright © 2026 boyuan. All rights reserved.
//

import UIKit

class MXSPuddleCmd {
    weak var owner: MXSBlobController?
    var animateCount:Int = 0
    
//    var unfairLock = os_unfair_lock()
//    func accessSharedResource() {
//        os_unfair_lock_lock(&unfairLock)
//        // 访问共享资源
//        print("访问共享资源")
//        // 修改共享资源
//        os_unfair_lock_unlock(&unfairLock)
//    }

    let queue = DispatchQueue(label: "com.example.serialQueue", attributes: .concurrent)
    func animateCountMins(_ mins:Int = 1) {
        queue.sync {
            // 访问/修改共享资源
            animateCount += mins
            
            self.owner?.puddleEnable(args: animateCount <= 0)
        }
    }
    
    var sumNumbTable:[Int:Int] = [:]
    var sum:Int = 0
    func clearDesktop() {
        sum = 0
    }
    func appendBlob(numb:Int, idx:Int) {
        let numb_note = sumNumbTable[idx]
        if numb_note != nil {
            sum-=numb_note!
            sum+=numb
        }
        else {
            sum+=numb
        }
        sumNumbTable[idx] = numb
        
        if sum == 0 {
            self.owner?.missionComplete()
        }
        
    }

    
}
