//
//  MXSFunctionMapCmd.swift
//  Possible
//
//  Created by Sunfei on 2024/5/24.
//  Copyright © 2024 boyuan. All rights reserved.
//

import Foundation

class MXSFunctionMapCmd {
    
    weak var vc: MXSViewController?
    
    init(vc: MXSViewController? = nil) {
        self.vc = vc
    }
    
    // 定义一个闭包字典，用于映射字符串到具体的闭包
    var functionMapVoid: [String: () -> Void] = [:]
    var functionMapPara: [String: (Any) -> Void] = [:]
    var functionMapDict: [String: ([String:Any]) -> Void] = [:]
    
    
//    func packageFunction
    
    
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
    
    
    
    
    
    public func test() {
        // 示例调用
        callFunction(byName: "function1") // 输出 "Function 1 called"
        callFunction(byName: "function2") // 输出 "Function 2 called"
        callFunction(byName: "function3") // 输出 "Function not found"
        
        callFunction(byName: "function11", withPara: ["key":"1.1"])
        callFunction(byName: "function11:", withPara: ["key":"1.2:"])
        callFunction(byName: "function11(args:)", withPara: ["key":"1.3(args:)"])
    }
}

