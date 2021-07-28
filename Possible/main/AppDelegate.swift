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

