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
        functionMapVoid["function1"] = function1
        functionMapVoid["function2"] = function2
        functionMapPara["function11"] = function11
    }
    
    public func test() {
        // 示例调用
        callFunction(byName: "function1") // 输出 "Function 1 called"
        callFunction(byName: "function2") // 输出 "Function 2 called"
        callFunction(byName: "function3") // 输出 "Function not found"
        
        callFunction(byName: "function11", withPara: ["key":"1.1"])
        callFunction(byName: "function11:", withPara: ["key":"1.2:"])
        callFunction(byName: "function11(args:)", withPara: ["key":"1.3(args:)"])
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
    // 定义一个闭包字典，用于映射字符串到具体的闭包
    var functionMapVoid: [String: () -> Void] = [:]
    var functionMapPara: [String: (Any) -> Void] = [:]
    var functionMapDict: [String: ([String:Any]) -> Void] = [:]
    
    // 通过字符串调用对应的函数
    func callFunction(byName functionName: String) {
        if let function = functionMapVoid[functionName] {
            function()
        } else {
            print("Function not found")
        }
    }
    func callFunction(byName functionName: String, withPara args: Any) {
        if let function = functionMapPara[functionName] {
            function(args)
        } else {
            print("Function not found")
        }
    }
    func callFunction(byName functionName: String, withDict args: [String:Any]) {
        if let function = functionMapDict[functionName] {
            function(args)
        } else {
            print("Function not found")
        }
    }
    /**------------------------------------**/
}
