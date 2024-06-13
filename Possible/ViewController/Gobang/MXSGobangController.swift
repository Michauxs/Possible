//
//  MXSGobangController.swift
//  Possible
//
//  Created by Sunfei on 2024/5/24.
//  Copyright © 2024 boyuan. All rights reserved.
//

import UIKit

class MXSGobangController: MXSViewController {
    
    let restartBtn = UIButton.init("Reset", fontSize: 14, textColor: .white, backgColor: .darkGray)
    
    var player: MXSHero = MXSHeroCmd.shared.getNewBlankHero()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let closeBtn = UIButton.init("Close", fontSize: 14, textColor: .white, backgColor: .darkGray)
        closeBtn.frame = CGRect.init(x: 10, y: 0, width: 64, height: 44)
        self.view.addSubview(closeBtn)
        closeBtn.addTarget(self, action: #selector(didCloseGameBtnClick), for: .touchUpInside)
        
        restartBtn.frame = CGRect.init(x: MXSSize.Sw - 10 - 64, y: 0, width: 64, height: 44)
        self.view.addSubview(restartBtn)
        restartBtn.addTarget(self, action: #selector(didRestartBtnClick), for: .touchUpInside)
    }
    
    @objc func didCloseGameBtnClick() {
        self.navigationController?.popViewController(animated: false)
    }
    @objc func didRestartBtnClick() {
        MXSLog("delayedFunc begin")
        
        player.twoBlockMethod(common: .mismatch) { parry, pokers, pokerWay, callback in
            MXSLog("one block")
            UIView.animate(withDuration: 2.0) {
                MXSLog("one blocking...")
                self.restartBtn.frame = CGRect.init(x: MXSSize.Sw - 10 - 164, y: 0, width: 64, height: 44)
            } completion: { finish in
                MXSLog("one block finish: animate")
                callback()
            }

        } two: { parry, pokers, pokerWay in
            MXSLog("two block")
        }

        
//        player.delayedFunc { parry in
////            let semaphore = DispatchSemaphore(value: 0)
////            semaphore.signal()
////            semaphore.wait()
//            MXSLog("delayedFunc begin")
//            UIView.animate(withDuration: 2.0) {
//                self.restartBtn.frame = CGRect.init(x: MXSSize.Sw - 10 - 164, y: 0, width: 64, height: 44)
//            } completion: { finished in
//                MXSLog("delayedFunc end: animate")
//            }
//            
//            MXSLog("delayedFunc end: code")
//        }.directFunc()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
