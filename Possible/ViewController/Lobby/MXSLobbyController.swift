//
//  MXSLobbyController.swift
//  Possible
//
//  Created by Sunfei on 2020/9/2.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit

class MXSLobbyController: MXSViewController, NetServiceBrowserDelegate {
    
    
    var onLineBtn:UIButton = UIButton("OFF", fontSize: 313, textColor: .dullLine)
    var publishBtn:UIButton = UIButton("Publish", fontSize: 614, textColor: .lightGray)
    
    /*---------------------------------------------*/
    @objc func tableDidSelectedRow(args:Array<Any>) {
        let ip:IndexPath = args[1] as! IndexPath
        let server = services[ip.row]
        if MXSNetServ.shared.connectToService(server) {
//            stopBrowser()
            
            MXSNetServ.shared.sendMsg([kMessageType:MessageType.request.rawValue, kMessageValue:"请求接连，来自：" + MXSNetServ.shared.name])
            MXSTIPMaskCmd.shared.showMaskWithTip("Waiting...", auto: false)
        }
    }
    
    override func havesomeMessage(_ dict:Dictionary<String, Any>) {
        super.havesomeMessage(dict)
        
        let type:MessageType = MessageType.init(rawValue: dict[kMessageType] as! Int)!
        switch type {
        case .request:
            let name = dict[kMessageValue] as! String
            let alert = UIAlertController.init(title: "接连请求", message: name, preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "拒绝", style: .cancel, handler: { (act) in
                MXSNetServ.shared.sendMsg([kMessageType:MessageType.replyRequest.rawValue, kMessageValue:0])
            }))
            alert.addAction(UIAlertAction.init(title: "接受", style: .default, handler: { (act) in
                MXSNetServ.shared.sendMsg([kMessageType:MessageType.replyRequest.rawValue, kMessageValue:1])
                let vc = MXSPVPServiceController()
                self.navigationController?.pushViewController(vc, animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
            
        case .replyRequest:
            MXSTIPMaskCmd.shared.dispearMaskTip()
            let value = dict[kMessageValue] as! Int
            if value == 0 {
                MXSTIPMaskCmd.shared.showMaskWithTip("connect be refused", auto:true)
                
            }
            else {
                MXSTIPMaskCmd.shared.showMaskWithTip("connected success", auto:true)
                let vc = MXSPVPCustomerController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        default: break
            
        }
    }
    
    
    var browserStatus : ServiceStatus = .unknown
    var servBrowser: NetServiceBrowser = {
        let browser = NetServiceBrowser.init()
        browser.includesPeerToPeer = true
        return browser
    }()
    
    var services: Array<NetService> = Array<NetService>.init()
    var mainTable: MXSTableView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let width = MXSSize.Sw * 0.25
//        let textSign = "情深不寿，慧极必伤"
        let textSign = "sometimes ever，\n          sometimes never."
        let textLabel = UILabel.init(text: textSign, fontSize: 1034, textColor: .darkText, align: .left)
        textLabel.sizeToFit()
        textLabel.frame = CGRect(x: 45, y: 90, width: textLabel.bounds.width, height: textLabel.bounds.height)
        view.addSubview(textLabel)
        
        let shadow = NSShadow.init()
        shadow.shadowOffset = CGSize.init(width: 0.5, height: 0.5)
        shadow.shadowColor = UIColor.gray
        shadow.shadowBlurRadius = 1;
        let abs = NSMutableAttributedString.init(string: textSign)
        abs.addAttribute(NSAttributedStringKey.shadow, value: shadow, range: NSMakeRange(0, textSign.count))
        textLabel.attributedText = abs
        
        /*---------------------------------------------*/
        let label_height:CGFloat = 44.0
        let head = UIView(frame: CGRect(x: width*3, y: 0, width: width, height: label_height))
        head.backgroundColor = .darkGray
        view.addSubview(head)
        
        let btn_width:CGFloat = 54.0
        onLineBtn.setTitle("OLine", for: .selected)
        onLineBtn.frame = CGRect.init(x: width-btn_width, y: 3, width: btn_width, height: 38)
        onLineBtn.layer.borderWidth = 1.0
        onLineBtn.layer.borderColor = UIColor.dullLine.cgColor
        head.addSubview(onLineBtn)
        onLineBtn.addTarget(self, action: #selector(deviceOffLine(btn:)), for: .touchUpInside)
        
        let deviceLabel = UILabel.init(text: "Services", fontSize: 615, textColor: .lightGray, align: .left)
        deviceLabel.frame = CGRect.init(x: 10, y: 0, width: width-10, height: label_height)
        head.addSubview(deviceLabel)
        
        mainTable = MXSTableView.init(frame: CGRect(x: head.frame.minX, y: label_height, width: width, height: MXSSize.Sh-label_height*2), style: .plain)
        mainTable?.register(cellNames: ["MXSDeviceCell"], delegate: MXSTableDlg(), vc: self)
        self.view.addSubview(mainTable!)
        mainTable?.dlg?.dlgData = services
        
        /*---------------------------------------------*/
        
        let pveBtn = UIButton.init("PVE", fontSize: 14, textColor: .black, backgColor: .darkGray)
        pveBtn.frame = CGRect.init(x: mainTable!.frame.minX, y: mainTable!.frame.maxY, width: width, height: label_height)
        view.addSubview(pveBtn)
        pveBtn.addTarget(self, action: #selector(didPVEBtnClick), for: .touchUpInside)
        
        /*---------------------------------------------*/
        
        let assemBtn = UIButton("Skill", fontSize: 614, textColor: .dullLine)
        assemBtn.frame = CGRect.init(x: 10, y: MXSSize.ScreenSize.height - 44, width: 96, height: 40)
        assemBtn.layer.borderWidth = 1.0
        assemBtn.layer.borderColor = UIColor.dullLine.cgColor
        view.addSubview(assemBtn)
        assemBtn.addTarget(self, action: #selector(assemBtnClick), for: .touchUpInside)
        

        
        publishBtn.setTitleColor(.theme, for: .selected)
        publishBtn.frame = CGRect.init(x: mainTable!.frame.minX - 70, y: assemBtn.frame.minY, width: 60, height: 40)
        view.addSubview(publishBtn)
        publishBtn.addTarget(self, action: #selector(didPublishBtnClick), for: .touchUpInside)
        /*---------------------------------------------*/
        
        browserStatus = .starting
        startBrowser()
    }
    
    
    //MARK: - actions
    @objc func didPVEBtnClick() {
        let vc = MXSPVESoloController()
        self.navigationController?.pushViewController(vc, animated: false)
    }
    @objc func assemBtnClick() {
        self.navigationController?.pushViewController(MXSSkillAssemController(), animated: false)
    }
    @objc func deviceOffLine(btn:UIButton) {
        //
        if browserStatus == .stoping || browserStatus == .starting { return }
        if btn.isSelected {//online -> off
            stopBrowser()
        }
        else {//off -> online
            if browserStatus == .working { return }
            startBrowser()
        }
    }
    @objc func didPublishBtnClick() {
        if publishBtn.isSelected {
            MXSNetServ.shared.stopService()
        }
        else {
            MXSNetServ.shared.publishOrRestart()
        }
    }
        
    override public func startBrowser() {
        MXSLog("netBrowser starting...")
        servBrowser.delegate = self
        servBrowser.searchForServices(ofType: "_mxs._tcp", inDomain: "local")
        //servBrowser.searchForBrowsableDomains()
    }
        
    override public func stopBrowser() {
        MXSLog("Browser stoping...")
        servBrowser.stop()
        services.removeAll()
        mainTable?.dlg?.dlgData = services
        mainTable?.reloadData()
    }
    
    //MARK: - service
    override func servicePublished() {
        publishBtn.isSelected = true
    }
    override func serviceStoped() {
        MXSLog("controller recev service stoped")
        publishBtn.isSelected = false
    }
    override func servicePublishFiled() {
        publishBtn.isSelected = false
    }
    
    //MARK: - delegate
    func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
        MXSLog("netServiceBrowserWillSearch")
        onLineBtn.isSelected = true
        browserStatus = .working
    }
    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        MXSLog("netServiceBrowserDidStopSearch")
        onLineBtn.isSelected = false
        browserStatus = .stop
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        MXSLog("self is: [" + "\(MXSNetServ.shared)" + "] didFind: [" + "\(service)" + "]")
        
        if MXSNetServ.shared == service {
            MXSLog("- didFind Self")
        }
        else {
            services.append(service)
            MXSLog("- didFind service +1 \n")
        }
        if !moreComing {
            mainTable?.dlg?.dlgData = services
            mainTable?.reloadData()
        }
    }
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        MXSLog("- didRemove")
        if !MXSNetServ.shared.isEqual(service)  {
            services.removeAll { (item) -> Bool in item.isEqual(service) }
        }
        if !moreComing {
            mainTable?.dlg?.dlgData = services
            mainTable?.reloadData()
        }
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFindDomain domainString: String, moreComing: Bool) {
        MXSLog(domainString)
    }

}
