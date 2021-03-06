//
//  AppDelegate.swift
//  Possible
//
//  Created by Sunfei on 2020/8/12.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, NetServiceDelegate, StreamDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        NSLog("HomeDirectory: %@", NSHomeDirectory())
        
//        NSLog("----------------")
//        for item in UIFont.familyNames {
//
//            NSLog("%@", item)
//            if item == "KaiTi_GB2312" || item == "Kaiti SC" || item == "Kaiti TC" || item == "STKaiti" {
//                for child in UIFont.fontNames(forFamilyName: item) {
//                    NSLog("- %@", child)
//                }
//                NSLog("\n")
//            }
//            NSLog("----------------")
//        }
        
        /*----------------------*/
        let root_vc = MXSLobbyController()
        let nav_vc = MXSNavigationController.init(rootViewController: root_vc)
        nav_vc.setNavigationBarHidden(true, animated: false)
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.rootViewController = nav_vc
        window?.makeKeyAndVisible()
        
        MXSNetServ.shared.belong = root_vc
        /*----------------------*/
//        let str = "https://www.baidu.com"
//        let request = URLRequest(url: NSURL(string: str)! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
//        let dataTask = URLSession.shared.dataTask(with: request) { (data, respons, error) in
//
//        }
//        dataTask.resume()
        
        //屏幕常亮
        application.isIdleTimerDisabled = true
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground")
//        MXSNetServ.shared.belong?.deviceOffLine()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
//        MXSNetServ.shared.belong?.startBrowser()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
    }


}

