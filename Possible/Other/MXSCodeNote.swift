//
//  MXSCodeNote.swift
//  Possible
//
//  Created by Sunfei on 2020/8/27.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit

class MXSCodeNote {

    func findIndexAtArrayForItem () {
        var array = Array<Int>()
        let one = 1
        
        /**1*/
        if let index = array.firstIndex(where: { (item) -> Bool in
            return item as AnyObject === one as AnyObject
        }){
            print(index)
            array.remove(at: index)
        }
        
        /**2*/
        if let index = array.firstIndex(where: {$0 as AnyObject === one as AnyObject}) {
            print("controller action pok at " + "\(index)")
        }
        
    }
    
    /**在Swift中，可以使用函数类型的参数，也可以使用函数类型的返回值。
     而作为返回值的函数，还能“捕获”外部的值，并多次使用它。
     这个特性，常可用来创建各种生成器。 */
    
    //随机数生成器函数
    func createRandomMan(start: Int, end: Int) ->() ->Int? {
        //根据参数初始化可选值数组
        var nums = [Int]();
        for i in start...end{
            nums.append(i)
        }
         
        func randomMan() -> Int! {
            if !nums.isEmpty {
                //随机返回一个数，同时从数组里删除
                let index = Int(arc4random_uniform(UInt32(nums.count)))
                return nums.remove(at: index)
            }
            else {
                //所有值都随机完则返回nil
                return nil
            }
        }
        return randomMan
    }
     /** //使用
     let random1 = createRandomMan(start: 1,end: 100)
     NSLog("%d", random1() ?? 0)
     NSLog("%d", random1() ?? 0)
     
     let random2 = createRandomMan(start: 2,end: 5)
     NSLog("%d", random2() ?? 0)
     NSLog("%d", random2() ?? 0)
     NSLog("%d", random2() ?? 0)
     NSLog("%d", random2() ?? 0)
     */
    
    func guardDemo() {
//        guard let index = player?.pokers?.firstIndex(where: {$0 === pick}) else {
//            return
//        }
    }
    
    func dataDemo(data:Data) {
        let array = data.withUnsafeBytes {
                            (pointer: UnsafePointer<Int8>) -> [Int8] in
            let buffer = UnsafeBufferPointer(start: pointer,
                                             count: data.count)
            return Array<Int8>(buffer)
        }
        print(array);
    
        
       let array_5 = data.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> [Int8] in
        if let ptrAddress = pointer.baseAddress, pointer.count > 0 {
            let pointer = ptrAddress.assumingMemoryBound(to: Int8.self) // here you got UnsafePointer<UInt8>
            let buffer = UnsafeBufferPointer(start: pointer,count: data.count)
            return Array<Int8>(buffer)
        }
        return Array<Int8>()
        }
        print("我的消息是 ",array_5)
    }
}
