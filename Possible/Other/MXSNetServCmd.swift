//
//  MXSNetServ.swift
//  Possible
//
//  Created by Sunfei on 2020/9/1.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit

enum MessageStatus : Int {
    case request
    case invite
    case replyRequest
    case replyInvite
    case joined
    case discard
}

class MXSNetServ: NetService, NetServiceDelegate, StreamDelegate {
    weak var belong: MXSLobbyController?
    
    var inputStream: InputStream?
    var outputStream: OutputStream?
    var expectConnectCount: Int = 2
    var currentConnectCount: Int = 0
    
    /**已启动发布*/
    var started: Bool = false
    /**发布完成*/
    var published: Bool = false
    
    static let shared : MXSNetServ = {
        let single = MXSNetServ.init(domain: "local", type: "_mxs._tcp", name: UIDevice.current.name, port: 0)
        single.includesPeerToPeer = true
        single.delegate = single
        return single
    }()
    
    func connectToService(_ serv:NetService) -> Bool {
        var s_in: InputStream?
        var s_out: OutputStream?
        let success = serv.getInputStream(&s_in, outputStream: &s_out)
        if success {
            MXSNetServ.shared.inputStream = s_in
            MXSNetServ.shared.outputStream = s_out
            
            openStreams()
        }
        return success
    }
    
    func openStreams() {
        MXSNetServ.shared.inputStream?.delegate = self
        MXSNetServ.shared.inputStream?.schedule(in: RunLoop.current, forMode: .defaultRunLoopMode)
        MXSNetServ.shared.inputStream?.open()
        
        MXSNetServ.shared.outputStream?.delegate = self
        MXSNetServ.shared.outputStream?.schedule(in: RunLoop.current, forMode: .defaultRunLoopMode)
        MXSNetServ.shared.outputStream?.open()
    }
    
    func closeStreams() {
        if (MXSNetServ.shared.inputStream != nil) {
            
            MXSNetServ.shared.inputStream?.remove(from: RunLoop.current, forMode: .defaultRunLoopMode)
            MXSNetServ.shared.inputStream?.close()
            MXSNetServ.shared.inputStream = nil
            
            MXSNetServ.shared.outputStream?.remove(from: RunLoop.current, forMode: .defaultRunLoopMode)
            MXSNetServ.shared.outputStream?.close()
            MXSNetServ.shared.outputStream = nil
        }
        currentConnectCount = 0
    }
    func publishOrRestart() {
        closeStreams()
        if !started {
            MXSNetServ.shared.publish(options: .listenForConnections)
            started = true
        }
    }
    func stopService() {
        MXSNetServ.shared.stop()
        published = false
        started = false
    }
    func offLine() {
        closeStreams()
        stopService()
    }
    
    
    func send(_ message:Dictionary<String, Any>) {
        let data = try? JSONSerialization.data(withJSONObject: message, options: .prettyPrinted)
        if (data != nil) {
            let length = data?.withUnsafeBytes { MXSNetServ.shared.outputStream?.write($0, maxLength: data!.count) }
            if length == 0 {
                print("send message Error")
            }
        }
        
        /**
         let l = JSONSerialization.writeJSONObject(message, to: MXSNetServ.shared.outputStream!, options: .prettyPrinted, error: nil)
         if l == 0 {
         print("send message Error")
         }
         */
        /**
        let data = message.data(using: .utf8)!
        _ = data.withUnsafeBytes { MXSNetServ.shared.outputStream?.write($0, maxLength: data.count) }
         */
        /**
         let value = Int(bigEndian: data.subdata(in: 0..<4).withUnsafeBytes { $0.pointee })
         let value = Int(bigEndian: data.subdata(in: 0..<4).withUnsafeBytes { $0.baseAddress!.bindMemory(to: Int.self, capacity: 4).pointee })
         */
         
        /**
         let bytes = [UInt8](data)
         */
         
        /**
         let bytes = data.withUnsafeBytes {
         [UInt8](UnsafeBufferPointer(start: $0, count: data.count))
         }
         print(bytes)
         */
         
        /**
         var msg = message
         let bytesW = MXSNetServ.shared.outputStream?.write(&msg, maxLength: MemoryLayout.size(ofValue: msg))
         if bytesW != MemoryLayout.size(ofValue: msg) {
         print("Error")
         }
         */
    }
    
    //MARK:stream delegate
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        print("\n=== aStream ===")
        switch eventCode {
        case .openCompleted:
            openCompleted()
        case .hasSpaceAvailable:
            print("can write")
        case .hasBytesAvailable:
            print("has bytes waiting")
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 4096)
            let in_stream = aStream as! InputStream
            let numberOfBytesRead = in_stream.read(buffer, maxLength: 4096)
            if numberOfBytesRead > 0 {
                let data1 = Data.init(bytesNoCopy: buffer, count: numberOfBytesRead, deallocator: .free)
                let dict1 = try? JSONSerialization.jsonObject(with: data1, options: .mutableContainers)
                if (dict1 != nil) {
                    receiveMessage(dict1 as! Dictionary<String, Any>)
                }
            }
            
            /**var buf: UInt8 = UInt8.init()
            let len = MXSNetServ.shared.inputStream?.read(&buf, maxLength: Int(UInt8.max))
            if len ?? 0 > 0 {
                let s = String.init(buf)
                self.belong!.receiveMsg(s)
            }*/
            
            /**
             while in_stream.hasBytesAvailable {
             }
             if in_stream.streamError != nil {
             break
             }
             */
            /*
             var b: UInt8 = 0
             let byteR = MXSNetServ.shared.inputStream?.read(&b, maxLength: Int(UInt8.max))
             if byteR ?? 0 > 0 {
                 self.belong!.receiveMsg(b)
             }
             */
            
        case .errorOccurred:
            print("errorOccurred")
        case .endEncountered:
            endEncountered()
        default:
            print("nothing")
        }
    }
    
    
    //MARK:notifies
    func openCompleted() {
        print("openCompleted +")
        currentConnectCount += 1
        /**完成链接 停止browser监测、当前service，输入、输出流不会停*/
        if currentConnectCount == expectConnectCount {
            print("openCompleted done")
            self.belong?.stopBrowser()
            stopService()
            belong?.setupForConnected()
        }
    }
    func receiveMessage(_ msg:Dictionary<String, Any>) {
        self.belong!.havesomeMessage(msg)
    }
    func endEncountered() {
        print("endEncountered")
        MXSNetServ.shared.publishOrRestart()
        belong?.startBrowser()
        belong?.setupForNewGame()
    }
    
    //MARK:serv delegate
    func netServiceDidPublish(_ sender: NetService) {
        print("netServiceDidPublish")
        published = true
    }
    func netServiceDidStop(_ sender: NetService) {
        print("netServiceDidStop")
    }
    func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
        print("didNotPublish")
    }
    
    func netService(_ sender: NetService, didAcceptConnectionWith inputStream: InputStream, outputStream: OutputStream) {
//        print(inputStream.)
        if MXSNetServ.shared.inputStream != nil {
            inputStream.open()
            inputStream.close()
            outputStream.open()
            outputStream.close()
        }
        else {
            stopService()
            
            MXSNetServ.shared.inputStream = inputStream
            MXSNetServ.shared.outputStream = outputStream
            
            openStreams()
        }
    }
    
    
    
    
}
