//
//  MXSColor.swift
//  Possible
//
//  Created by Sunfei on 2020/8/25.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit

public extension UIColor {

    struct RGBA {
        var r: UInt8
        var g: UInt8
        var b: UInt8
        var a: UInt8
    }
    
//    class var random: UIColor {
//        get {
//            return UIColor.init(red: CGFloat(arc4random() % 256)/255, green: CGFloat(arc4random() % 256)/255, blue: CGFloat(arc4random() % 256)/255, alpha: 1)
//        }
//    }
    
    class var lightBlack: UIColor {
        get {
            return UIColor.init(white: 0.25, alpha: 1)
        }
    }
    
    class var dullWhite: UIColor {
        get {
            return UIColor.init(white: 0.75, alpha: 1)
        }
    }
    class var dullLine: UIColor {
        get {
            return UIColor.init(white: 0.55, alpha: 1)
        }
    }
    class var darkLine: UIColor {
        get {
            return UIColor.init(white: 0.35, alpha: 1)
        }
    }
    
    class var grayline: UIColor {
        get {
            return UIColor.init(white: 0.85, alpha: 1)
        }
    }
    //
    class var theme: UIColor {
        get {
            return UIColor.init(red: 90/255, green: 210/255, blue: 200/255, alpha: 1)
        }
    }
    
    //MARK: - alpha
    class var alphaWhite: UIColor {
        get {
            return UIColor.init(white: 1, alpha: 0.25)
        }
    }
    class var alphaBlack: UIColor {
        get {
            return UIColor.init(white: 0, alpha: 0.25)
        }
    }
    
    /// 将十六进制的字符串转化为 `UInt32` 类型的数值, 能够解析的最大值为 `0xFFFFFFFFFF` 超过此值返回 `UInt32.max`
    /// - Parameter hex: 十六进制字符串，如果字符串中包含非十六进制，那么只会将第一个非十六进制之前的十六进制转化为 `UInt32`。如果第一个字符就是非十六进制的则会返回 `nil`
    /// - Returns: 转换之后的 `UInt32` 类型的数值
    static func hexStringToUInt32(hex: String) -> UInt32? {
        let hexString = hex.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: hexString)
        var result: UInt64 = 0
        if scanner.scanHexInt64(&result) {
            return result > UInt32.max ? UInt32.max : UInt32(result)
        } else {
            return nil
        }
    }
    
    /// 将 UInt32 的颜色值转换成 RGBA
    /// - Parameter from: UInt32 类型的颜色值
    /// - Returns: RGBA
    static func getRGBA(from: UInt32) -> RGBA {
        func getbyte(_ value: UInt32) -> UInt8 {
            return UInt8(value & 0xFF)
        }
        let r = getbyte(from >> 24)
        let g = getbyte(from >> 16)
        let b = getbyte(from >> 8)
        let a = getbyte(from)
        return RGBA(r: r, g: g, b: b, a: a)
    }
    
    /// 获取 UIColor 的 RGBA 值
    var rgba: RGBA? {
        let numberOfComponents = self.cgColor.numberOfComponents
        // 使用图片创建的 Color（`UIColor(patternImage:)`） 的 numberOfComponents 数量为 1
        if numberOfComponents == 1 {
            return nil
        } else if numberOfComponents == 2 {
            guard let rgb = self.cgColor.components?[0],
                let a = self.cgColor.components?[1] else { return nil }
            return RGBA(r: UInt8(rgb * 255),
                        g: UInt8(rgb * 255),
                        b: UInt8(rgb * 255),
                        a: UInt8(a * 255))
        } else if numberOfComponents == 4 {
            guard let r = self.cgColor.components?[0],
                let g = self.cgColor.components?[1],
                let b = self.cgColor.components?[2],
                let a = self.cgColor.components?[3] else { return nil }
            return RGBA(r: UInt8(r * 255),
                        g: UInt8(g * 255),
                        b: UInt8(b * 255),
                        a: UInt8(a * 255))
        } else {
            return nil
        }
    }
    
    /// 使用十六进制颜色值初始化 UIColor
    /// - Parameter hex: 十六进制颜色值
    convenience init?(hexColor: String) {
        var hex = hexColor.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        // 验证色值的有效性
        let legalCharacter = hex.uppercased().map { String($0) }.filter { c -> Bool in
            let c1 = c > "9" && c < "A"
            let c2 = c < "0"
            let c3 = c > "F"
            return  c1 || c2 || c3
        }.count == 0
        
        guard legalCharacter else { return nil }
        if hex.count == 3 {
            hex = hex.map { String($0) }.map { $0 + $0 }.joined().appending("FF")
        } else if hex.count == 4 {
            hex = hex.map { String($0) }.map { $0 + $0 }.joined()
        } else if hex.count == 6 {
            hex = hex.appending("FF")
        } else if hex.count == 8 {
        } else {
            return nil
        }
        
        guard let colorValue = Self.hexStringToUInt32(hex: hex) else { return nil }
        let rgba = Self.getRGBA(from: colorValue)
        self.init(red: CGFloat(rgba.r) / 255,
                  green: CGFloat(rgba.g) / 255,
                  blue: CGFloat(rgba.b) / 255,
                  alpha: CGFloat(rgba.a) / 255)
    }
    
    /// 使用 RGBA 的 UInt8 数值初始化 UIColor
    /// - Parameters:
    ///   - red: 红色值
    ///   - green: 绿色值
    ///   - blue: 蓝色值
    ///   - alpha: 透明度
    convenience init(_ R: UInt8, _ G: UInt8, _ B: UInt8) {
        self.init(red: CGFloat(R) / 255.0,
                  green: CGFloat(G) / 255.0,
                  blue: CGFloat(B) / 255.0,
                  alpha: 1.0)
    }
    
    /// 使用 RGB 的 UInt8 数值,以及 alpha 0~1 初始化 UIColor
    /// - Parameters:
    ///   - red: 红色值
    ///   - green: 绿色值
    ///   - blue: 蓝色值
    ///   - alpha: 透明度 0~1
    convenience init(R: UInt8, G: UInt8, B: UInt8, A: CGFloat) {
        self.init(red: CGFloat(R) / 255.0,
                  green: CGFloat(G) / 255.0,
                  blue: CGFloat(B) / 255.0,
                  alpha: A)
    }
    
    /// 十六进制色值
    var hexValue: String? {
        guard let rgba = rgba else { return nil }
        return String(format: "%02X%02X%02X%02X", rgba.r,rgba.g,rgba.b,rgba.a)
    }
    
    /// 生成随机色
    static var random: UIColor {
        let r = CGFloat.random(in: 0...1)
        let g = CGFloat.random(in: 0...1)
        let b = CGFloat.random(in: 0...1)
        let a = CGFloat.random(in: 0...1)
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
