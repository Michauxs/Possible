//
//  AppDelegate.swift
//  Possible
//
//  Created by Sunfei on 2020/8/12.
//  Copyright © 2020 boyuan. All rights reserved.
//

/**
 测试工具Core Animation。可以在Xcode->Open Develeper Tools->Instruments中找到
 用来监测Core Animation性能，提供可见的FPS值，并且提供几个选项来测量渲染性能。如下图：
 每个选项的功能：

 Color Blended Layers：这个选项如果勾选，你能看到哪个layer是透明的，GPU正在做混合计算。显示红色的就是透明的，绿色就是不透明的。
 Color Hits Green and Misses Red：如果勾选这个选项，且当我们代码中有设置shouldRasterize为YES，那么红色代表没有复用离屏渲染的缓存，绿色则表示复用了缓存。我们当然希望能够复用。
 Color Copied Images：按照官方的说法，当图片的颜色格式GPU不支持的时候，Core Animation会拷贝一份数据让CPU进行转化。
 例如从网络上下载了TIFF格式的图片，则需要CPU进行转化，这个区域会显示成蓝色。还有一种情况会触发Core Animation的copy方法，就是字节不对齐的时候。如下图：

 Color Immediately：默认情况下Core Animation工具以每毫秒10次的频率更新图层调试颜色，如果勾选这个选项则移除10ms的延迟。对某些情况需要这样，但是有可能影响正常帧数的测试。
 Color Misaligned Images：勾选此项，如果图片需要缩放则标记为黄色，如果没有像素对齐则标记为紫色。像素对齐我们已经在上面有所介绍。
 Color Offscreen-Rendered Yellow：用来检测离屏渲染的，如果显示黄色，表示有离屏渲染。当然还要结合Color Hits Green and Misses Red来看，是否复用了缓存。
 Color OpenGL Fast Path Blue：这个选项对那些使用OpenGL的图层才有用，像是GLKView或者 CAEAGLLayer，如果不显示蓝色则表示使用了CPU渲染，绘制在了屏幕外，显示蓝色表示正常。
 Flash Updated Regions：当对图层重绘的时候回显示黄色，如果频繁发生则会影响性能。可以用增加缓存来增强性能。

 作者：青火
 链接：https://www.jianshu.com/p/cff0d1b3c915
 来源：简书
 著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
 
 */

import UIKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, NetServiceDelegate, StreamDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    func testSomething() {
//        if MXSPokerCmd.shared.shuffle() {
//            let pokers = MXSPokerCmd.shared.push(1)
//            MXSLog(pokers, "some pokers")
//
//            let hero = MXSHeroCmd.shared.getNewBlankHero()
//            let hero2 = MXSHeroCmd.shared.getNewBlankHero()
//            let hero3 = MXSHeroCmd.shared.getNewBlankHero()
//            MXSLog(hero, "hero")
//            MXSLog(Unmanaged.passRetained(hero3), "hero3")//pointee
//            withUnsafeBytes(of: &hero) { ptr in
//                MXSLog(ptr, "hero'ptr-&")
//            }
//            withUnsafeBytes(of: hero) { ptr in
//                MXSLog(ptr, "hero'ptr")
//            }
            
//            var memoryPointer: Int64 = 0
//            withUnsafePointer(to: &hero) { ptr in
//                            memoryPointer = unsafeBitCast(ptr.pointee, to: Int64.self)
//                print(memoryPointer)
//            }
            /**
             withUnsafePointer(to: obj) { #ptr in print(ptr)} ( let #ptr = withUnsafeMutablePointer(to: obj, {$0}) ) =指针的地址
             Unmanaged.passRetained(obj) = #ptr.pointee
             **/
//            withUnsafePointer(to: hero) { ptr in
//                MXSLog(ptr, "hero'ptr  ")//hero'ptr : 0x00000001 6ef1 d100
//            }
//            withUnsafePointer(to: &hero) { ptr in
//                MXSLog(ptr, "hero'ptr-&")//hero'ptr-& : 0x00000001 6ef1 d128
//            }
//            withUnsafePointer(to: &hero) { ptr in
//                MXSLog(ptr, "hero'ptr")//hero'ptr : 0x00000001 6b16 d100
//            }
//            withUnsafePointer(to: hero) { ptr in
//                MXSLog(ptr, "hero'ptr-&")//hero'ptr-& : 0x00000001 6b16 d128
//            }
//        }
//        if MXSPokerCmd.shared.shuffle() {
//            var pokers = MXSPokerCmd.shared.push(3)
//            let pokers2 = pokers //var
//            pokers.removeAll()
//            MXSLog(pokers, "pokers ")//[]
//            MXSLog(pokers2, "pokers2 ")//[p,p,p]
//        }
//
//        var arr = [[1],[2],[3]]
//        MXSLog(Unmanaged.passRetained(arr.first as AnyObject), "arr.0")
//        let arr2 = arr
//        arr.removeAll()
//        MXSLog(arr, "arr")//[]
//        MXSLog(arr2, "arr2")//[1,2,3]
//        //        MXSLog(Unmanaged.passRetained(arr2.first as AnyObject), "arr2.0")
//        MXSLog(String(format: "%p", arr2.first!), "arr2.0")
//
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
        
    }
    
    // 将要通知
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
          print("willPresent")
    }
        
    // 已经完成推送
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
          print("didReceive")
          completionHandler()
    }
    func setNotification() {
        // 通知内容设置
       let content = UNMutableNotificationContent()
       content.title = "推送标题"
       content.subtitle = "推送子标题"
       content.body = "推送消息主体内容"
       content.badge = 2   // 图标右上角数字
       content.categoryIdentifier = "categoryIdentifier"  // 通知标识
       content.sound = UNNotificationSound.default() // 推送声音
       content.launchImageName = "01.png"  // 启动图片
     
       do {
           /*
            在创建附件的方法：
            （1）URL必须是一个有效地文件路径，
            （2）option 是共有4个选项，
            UNNotificationAttachmentOptionsTypeHintKey: 如果添加附件的文件名字中没有类型，就要靠该键值来确定文件类型；
            UNNotificationAttachmentOptionsThumbnailHiddenKey: 是一个BOOL值，为YES时候，缩略图将隐藏，默认为YES；
            UNNotificationAttachmentOptionsThumbnailClippingRectKey: 是一个矩形CGRect 剪贴图片的缩略图的键值；
            UNNotificationAttachmentOptionsThumbnailTimeKey: 如果附件是一个视频的话，可以用这值来指定视频中的某一秒为视频的缩略图
            */
           // 设置通知下拉的图片，可以是图片，视频，音频
           let attachment = try UNNotificationAttachment(identifier: "note1", url: URL(fileURLWithPath: Bundle.main.path(forResource: "01", ofType: ".png")!), options: nil)
           content.attachments = [attachment]
       } catch  {
            print(error)
       }
       
       // 通知下拉时候的动作
       let action = UNNotificationAction(identifier: "action", title: "进入应用", options: UNNotificationActionOptions.foreground)
       let clearAction = UNNotificationAction(identifier: "clearaction", title: "忽略", options: UNNotificationActionOptions.destructive)
       let category = UNNotificationCategory(identifier: "categoryIdentifier", actions: [action,clearAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
       
       ///1，一段时间后触发（UNTimeIntervalNotificationTrigger）
       // 通知触发器，10秒触发
       let timeTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
       /* 2.指定日期时间触发（UNCalendarNotificationTrigger）
        // 下面代码我们设置2019年11月11日凌晨触发推送通知。
        var components = DateComponents()
        components.year = 2019
        components.month = 11
        components.day = 11
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // 下面代码我们设置每周一上午8点都会触发推送通知。
        var components = DateComponents()
        components.weekday = 2 //周一
        components.hour = 8 //上午8点
        components.second = 30 //30分
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        */
       
       /* 3，根据位置触发（UNLocationNotificationTrigger）
        // 该触发器支持进入某地触发、离开某地触发、或者两种情况均触发。下面代码设置成当手机进入到指定点（纬度：52.10，经度：51.11）200 米范围内时会触发推送通知。（注意：这里我们需要 import CoreLocation 框架）
        let coordinate = CLLocationCoordinate2D(latitude: 52.10, longitude: 51.11)
        let region = CLCircularRegion(center: coordinate, radius: 200, identifier: "center")
        region.notifyOnEntry = true  //进入此范围触发
        region.notifyOnExit = false  //离开此范围不触发
        let trigger = UNLocationNotificationTrigger(region: region, repeats: true)
        */
       // 请求标识符

       let requestidentifier = "requestidentifier"
       let request = UNNotificationRequest(identifier: requestidentifier, content: content, trigger: timeTrigger)
       // 将通知请求添加到发送中心
        UNUserNotificationCenter.current().add(request) { (error: Error?) in
           
       }
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        NSLog("HomeDirectory: %@", NSHomeDirectory())
        testSomething()
        
        /*----------------------*/
        
//        let type = UIUserNotificationType(rawValue: UIUserNotificationType.alert.rawValue | UIUserNotificationType.badge.rawValue | UIUserNotificationType.sound.rawValue)
//        let setting = UIUserNotificationSettings(types: type, categories: nil)
//        application.registerUserNotificationSettings(setting)
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert, .badge]) { auth, error in
            if auth {
                UNUserNotificationCenter.current().delegate = self
                //self.setNotification()
            }
        }
        
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
        MXSLog("applicationDidEnterBackground")
//        MXSNetServ.shared.belong?.deviceOffLine()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
//        MXSNetServ.shared.belong?.startBrowser()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        MXSLog("applicationWillTerminate")
    }

//    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
//        return .landscapeLeft
//    }
}

