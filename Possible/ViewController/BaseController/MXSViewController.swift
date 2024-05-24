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
    
    public func receiveArgsBePost(args:Any) {
        
    }
    public func receiveArgsBeBack(args:Any) {
        
    }
    
//    let functionMapCmd: MXSFunctionMapCmd = MXSFunctionMapCmd()
    weak var functionMapCmd = MXSFunctionMapCmd()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(100, 100, 120)
        
        packageFunctionName()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        MXSNetServ.shared.belong = self
    }
    
    // MARK: - common    
    public func someoneHeroTaped(_ heroView: MXSHeroView) {
        
    }
    public func playerCollectPoker(_ poker:MXSPoker) {
        
    }
    
    
    
    /**------------------------------------**/
    func function1() {
        print("Function 1 called")
    }
    func function2() {
        print("Function 2 called")
    }
    func function11(args:Any) {
        let dict = args as! [String:Any]
        let value = dict["key"] as! String
        print("Function 11 called with args: " + value)
    }
    public func packageFunctionName() {
        // 将函数作为闭包存储在字典中
        weak var weakself = self
        functionMapCmd?.functionMapVoid["function1"] = weakself?.function1
        functionMapCmd?.functionMapPara["function11"] = weakself?.function11
    }
    
    /**------------------------------------**/
    
    public func test2() {
        let myClass = MXSViewController()
        let mirror = Mirror(reflecting: myClass)
        
        if let func1 = mirror.descendant("hello") as? () -> () {
            func1()
        }
        
        if let func2 = mirror.descendant("add(a:b:)") as? (Int, Int) -> Int {
            let result = func2(1, 2)
            print(result)
        }
    }
    public func testVoidFunc() {
        print("Hello, World!")
    }
    func add(a: Int, b: Int) -> Int {
        return a + b
    }
    
    
    // MARK: - NetServ
    /***/
    func havesomeMessage(_ dict:Dictionary<String, Any>) {
        MXSLog(dict)
    }
    public func startBrowser() { }
    public func stopBrowser() { }
    public func setupForNewGame() { }
    public func setupForConnected() { }
    
    public func servicePublished() { }
    public func serviceStoped() { }
    public func servicePublishFiled() { }
    
    /**------------------------------------**/
    
    /**------------------------------------**/
}
