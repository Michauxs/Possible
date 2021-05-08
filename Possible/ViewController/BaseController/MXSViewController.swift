//
//  MXSViewController.swift
//  HaiOn
//
//  Created by Sunfei on 2020/8/12.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit

class MXSViewController: UIViewController {

    lazy var maskTipView:MXSTIPMask = {
        return MXSTIPMask.init()
    }()
    
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
    
    
    // MARK: - NetServ
    /***/
    func havesomeMessage(_ dict:Dictionary<String, Any>) {
        print(dict)
    }
    public func startBrowser() { }
    public func stopBrowser() { }
    public func setupForNewGame() { }
    public func setupForConnected() { }
}
