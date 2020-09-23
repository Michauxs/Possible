//
//  MXSViewController.swift
//  HaiOn
//
//  Created by Sunfei on 2020/8/12.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit

class MXSViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(100, 100, 120)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        MXSNetServ.shared.belong = self
    }
    
    // MARK: - common
//    public func someonePokerTaped(_ pokerView: MXSPokerView) {
//        
//    }
    
    public func someoneHeroTaped(_ heroView: MXSHeroView) {
        
    }
    public func playerCollectPoker(_ poker:MXSPoker) {
        
    }
    public func someHeroHPZero(_ hero:MXSHero) {
        
    }
    
    /*

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
