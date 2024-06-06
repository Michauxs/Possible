//
//  MXSNetServ.swift
//  Possible
//
//  Created by Sunfei on 2020/9/1.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit

enum MessageType : Int {
    case unknown = 0
    case request
    case cancelRquest
    case replyRequest
    case invite
    case cancelInvite
    case replyInvite
    case readyOn
    case joined
    case showHero
    case pickHero
    case discard
    /**发牌*/
    case dealcard
    /**攻防转化*/
    case turnOver
    /**报告状态：hp*/
    case report
    case endGame
}
enum ServiceStatus : Int {
    case unknown = 0
    case starting
    case working
    case stoping
    case stop
}

class MessageModel {
    var type: MessageType = .unknown
    var content: Any
    init(type: MessageType, content: Any) {
        self.type = type
        self.content = content
    }
}

class MXSNetServ: NetService, NetServiceDelegate, StreamDelegate {
    weak var belong: MXSViewController?
    
    var inputStream: InputStream?
    var outputStream: OutputStream?
    var expectConnectCount: Int = 2
    var currentConnectCount: Int = 0
    
    var currentConnectServ:NetService?
    /**已启动发布*/
    var status : ServiceStatus = .unknown
    
    static let shared : MXSNetServ = {
        let single = MXSNetServ.init(domain: "local", type: "_mxs._tcp", name: UIDevice.current.name, port: 0)
        single.includesPeerToPeer = true
        single.delegate = single
        return single
    }()
    
    func connectToService(_ serv:NetService) -> Bool {
        var s_in: InputStream?
        var s_out: OutputStream?
        MXSLog("connectToService getInputStream")
        let success = serv.getInputStream(&s_in, outputStream: &s_out)
        if success {
            MXSNetServ.shared.inputStream = s_in
            MXSNetServ.shared.outputStream = s_out
            MXSLog("connectToService success")
            currentConnectServ = serv
            
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
            
            MXSNetServ.shared.inputStream?.close()
            MXSNetServ.shared.inputStream?.remove(from: RunLoop.current, forMode: .defaultRunLoopMode)
            MXSNetServ.shared.inputStream = nil
            
            MXSNetServ.shared.outputStream?.close()
            MXSNetServ.shared.outputStream?.remove(from: RunLoop.current, forMode: .defaultRunLoopMode)
            MXSNetServ.shared.outputStream = nil
        }
        currentConnectCount = 0
    }
    
    //MARK: - act
    func publishOrRestart() {
        if status == .starting || status == .working || status == .stoping {
            return
        }
        MXSLog("netService starting...")
        closeStreams()
        status = .starting
        MXSNetServ.shared.publish(options: .listenForConnections)
    }
    func stopService() {
        if status == .stoping {
            return
        }
        MXSLog("netService stoping...")
        status = .stoping
        MXSNetServ.shared.stop()
    }
    func offLine() {
        closeStreams()
        stopService()
    }
    func disConnect() {
//        closeStreams()
    }
    
    //MARK: - serv delegate
    func netServiceDidPublish(_ sender: NetService) {
        MXSLog("netServiceDidPublish")
        status = .working
        self.belong?.servicePublished()
    }
    func netServiceDidResolveAddress(_ sender: NetService) {
        print("netServiceDidResolveAddress", sender.name, sender.addresses as Any, sender.hostName as Any, sender.addresses?.first as Any)
        let data = sender.txtRecordData()
        let dict = NetService.dictionary(fromTXTRecord: data!)
        let info = String.init(data: dict["node"]!, encoding: String.Encoding.utf8)
        MXSLog(info as Any, "mac info = ");

    }
    func netServiceDidStop(_ sender: NetService) {
        status = .stop
        MXSLog(status, "netServiceDidStop")
        self.belong?.serviceStoped()
        
        MXSLog(inputStream as Any)
        MXSLog(outputStream as Any)
    }
    func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
        MXSLog("didNotPublish")
        status = .stop
        self.belong?.servicePublishFiled()
    }
    
    func netService(_ sender: NetService, didAcceptConnectionWith inputStream: InputStream, outputStream: OutputStream) {
        MXSLog("didAcceptConnectionWith inputStream, outputStream")
        
        if MXSNetServ.shared.inputStream != nil {
            MXSLog("didAcceptConnectionWith other")
            inputStream.open()
            inputStream.close()
            outputStream.open()
            outputStream.close()
        }
        else {
            MXSLog("didAcceptConnectionWith ")
//            stopService()

            MXSNetServ.shared.inputStream = inputStream
            MXSNetServ.shared.outputStream = outputStream
            openStreams()
        }
    }
    
    
    //MARK: - stream delegate
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        MXSLog(aStream, "\n=== aStream ===")
        switch eventCode {
        case .openCompleted:
            MXSLog("openCompleted +")
            currentConnectCount += 1
            /**完成链接 停止browser监测、当前service，输入、输出流不会停*/
            if currentConnectCount == expectConnectCount {
                MXSLog("openCompleted done")
    //            self.belong?.stopBrowser()
    //            stopService()
                belong?.setupForConnected()
            }
        case .hasSpaceAvailable:
            MXSLog("can write")
        case .hasBytesAvailable:
            MXSLog("has bytes waiting")
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
            MXSLog("errorOccurred")
        case .endEncountered:
            MXSLog("endEncountered")
            closeStreams()
            
        default:
            MXSLog("nothing")
        }
    }
    
    //MARK:notifies msg
    func receiveMessage(_ message:Dictionary<String, Any>) {
        if let type: MessageType = MessageType.init(rawValue: message[kMsgType] as! Int), let content: Any = message[kMsgValue] {
            
            let model: MessageModel = .init(type: type, content: content)
            self.belong!.haveAmessage(model)
        }
    }
    
    func sendMessage(_ model: MessageModel) {
        var message:Dictionary<String, Any> = [String:Any]()
        message[kMsgType] = model.type.rawValue
        message[kMsgValue] = model.content
        MXSLog(message, "send message 123: ")
        let data = try? JSONSerialization.data(withJSONObject: message, options: .prettyPrinted)
        if (data != nil) {
            let length = data?.withUnsafeBytes { MXSNetServ.shared.outputStream?.write($0, maxLength: data!.count) }
            if length == 0 {
                MXSLog("send message Error")
            }
        }
        
        /**
         let l = JSONSerialization.writeJSONObject(message, to: MXSNetServ.shared.outputStream!, options: .prettyPrinted, error: nil)
         if l == 0 {
         MXSLog("send message Error")
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
         MXSLog(bytes)
         */
         
        /**
         var msg = message
         let bytesW = MXSNetServ.shared.outputStream?.write(&msg, maxLength: MemoryLayout.size(ofValue: msg))
         if bytesW != MemoryLayout.size(ofValue: msg) {
         MXSLog("Error")
         }
         */
    }
    
}
