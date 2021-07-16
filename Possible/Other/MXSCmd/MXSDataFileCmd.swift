//
//  MXSDataFileCmd.swift
//  MXSSwift
//
//  Created by Sunfei on 2018/11/1.
//  Copyright © 2018年 MXS. All rights reserved.
//

import UIKit

let kMXSVideoNamesHide = "kMXSVideoNamesHide"

class MXSDataFileCmd: NSObject {
    
    func writeDataFile(data : Data, key :String) {
        let dir = dataFileDirectory()
        
        if dir.count != 0 {
            try? data.write(to: URL.init(fileURLWithPath: dir))
        }
        
    }
    
    func dataFileDirectory () -> String {
        let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        let fileDir = docDir!+"/DataFiles"
        
        var realDir = ""
        
//        var isDir : ObjCBool = ObjCBool(false)
        var isDir : ObjCBool = false
        let isExist = FileManager.default.fileExists(atPath: fileDir, isDirectory: &isDir)
        if !(isDir.boolValue && isExist) {
            do {
                try FileManager.default.createDirectory(atPath: fileDir, withIntermediateDirectories: true, attributes: nil)
                realDir = fileDir
            } catch {
                
            }
        }
        return realDir
    }
    
    
    public func setPreference (data : Any, key : String) {
        UserDefaults.standard.set(data, forKey: key)
    }
    
    public func getPreference (key : String) -> Any {
        return UserDefaults.standard.object(forKey: key) as Any
    }
    
    public func delPreference (key : String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    public func appendPreference (_ data : Any, key : String) {
        var arr = UserDefaults.standard.array(forKey: key)
        if (arr == nil) {
            arr = Array.init()
        }
        arr?.append(data)
        UserDefaults.standard.set(arr, forKey: key)
    }
}
