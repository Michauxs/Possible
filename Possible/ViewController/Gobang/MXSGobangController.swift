//
//  MXSGobangController.swift
//  Possible
//
//  Created by Sunfei on 2024/5/24.
//  Copyright © 2024 boyuan. All rights reserved.
//

import UIKit

class MXSGobangController: MXSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let closeBtn = UIButton.init("Close", fontSize: 14, textColor: .white, backgColor: .darkGray)
        closeBtn.frame = CGRect.init(x: 10, y: 0, width: 64, height: 44)
        self.view.addSubview(closeBtn)
        closeBtn.addTarget(self, action: #selector(didCloseGameBtnClick), for: .touchUpInside)
        
    }
    
    deinit {
        MXSLog("MXSGobangController deinit")
    }
    
    @objc func didCloseGameBtnClick() {
        self.navigationController?.popViewController(animated: false)
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
