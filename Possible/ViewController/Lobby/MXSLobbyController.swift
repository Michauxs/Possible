//
//  MXSLobbyController.swift
//  Possible
//
//  Created by Sunfei on 2020/9/2.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit

class MXSLobbyController: MXSViewController, NetServiceBrowserDelegate
{
    
    /*---------------------------------------------*/
    @objc func tableDidSelectedRow(args:Array<Any>) {
        let ip:IndexPath = args[1] as! IndexPath
        let server = services[ip.row]
        if MXSNetServ.shared.connectToService(server) {
            stopBrowser()
            
            MXSNetServ.shared.send([kMessageType:MessageStatus.request.rawValue, kMessageValue:"Mymy"])
            MXSTIPMaskCmd.shared.showMaskWithTip("Waiting...", auto: false)
        }
    }
    
    override func havesomeMessage(_ dict:Dictionary<String, Any>) {
        print(dict)
        
        let type:MessageStatus = MessageStatus.init(rawValue: dict[kMessageType] as! Int)!
        switch type {
        case .request:
            let name = dict[kMessageValue] as! String
            let alert = UIAlertController.init(title: "接连请求", message: name, preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "N", style: .cancel, handler: { (act) in
                MXSNetServ.shared.send([kMessageType:MessageStatus.replyRequest.rawValue, kMessageValue:0])
            }))
            alert.addAction(UIAlertAction.init(title: "Y", style: .default, handler: { (act) in
                MXSNetServ.shared.send([kMessageType:MessageStatus.replyRequest.rawValue, kMessageValue:1])
            }))
            self.present(alert, animated: true, completion: nil)
        case .replyRequest:
            MXSTIPMaskCmd.shared.dispearMaskTip()
            let value = dict[kMessageValue] as! Int
            if value == 0 { 
                MXSTIPMaskCmd.shared.showMaskWithTip("connect be refused", auto:true)
                MXSNetServ.shared.closeStreams()
//                startBrowser()
            }
            else {
                MXSTIPMaskCmd.shared.showMaskWithTip("connected success", auto:true)
            }
            
        default: break
            
        }
    }
    
    var startedBrowser:Bool = false
    var servBrowser: NetServiceBrowser = {
        let browser = NetServiceBrowser.init()
        browser.includesPeerToPeer = true
        return browser
    }()
    
    var services: Array<NetService> = Array<NetService>.init()
    var mainTable: MXSTableView?
    
    let closeBtn = UIButton.init(frame: CGRect.init(x: MXSSize.Sw*0.5, y: 0, width: 60, height: 40))
    
    @objc func didPVEBtnClick() {
        let vc = MXSGroundController.init()
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true) {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let width = MXSSize.Sw * 0.25
//        let textSign = "情深不寿，慧极必伤"
        let textSign = "sometimes ever，sometimes never."
        //"sometimes ever，sometimes never."
//        let text_center = CGPoint(x: width, y: MXSSize.Sh*0.5)
        let textLabel = UILabel.init(text: textSign, fontSize: 1034, textColor: .gray, align: .left)
        textLabel.sizeToFit()
        view.addSubview(textLabel)
        
        let textLabel2 = UILabel.init(text: textSign, fontSize: 1034, textColor: .darkText, align: .left)
        textLabel.frame = CGRect(x: 45.5, y: 90.5, width: textLabel.frame.width, height: textLabel.frame.height)
        textLabel2.frame = CGRect(x: 45, y: 90, width: textLabel.frame.width, height: textLabel.frame.height)
        view.addSubview(textLabel2)
        
        /*---------------------------------------------*/
        
        let label_height:CGFloat = 44.0
        let deviceLabel = UILabel.init(text: "Online Device", fontSize: 615, textColor: .lightGray, align: .left)
        deviceLabel.backgroundColor = .darkGray
        deviceLabel.frame = CGRect.init(x: width*3, y: 0, width: width, height: label_height)
        view.addSubview(deviceLabel)
        
        mainTable = MXSTableView.init(frame: CGRect(x: deviceLabel.frame.minX, y: label_height, width: width, height: MXSSize.Sh-label_height*2), style: .plain)
        mainTable?.register(cellNames: ["MXSDeviceCell"], delegate: MXSTableDlg(), vc: self)
        self.view.addSubview(mainTable!)
        mainTable?.dlg?.dlgData = services
        
        let pveBtn = UIButton.init("PVE", fontSize: 14, textColor: .black, backgColor: .darkGray)
        pveBtn.frame = CGRect.init(x: deviceLabel.frame.minX, y: MXSSize.Sh-label_height, width: width, height: label_height)
        view.addSubview(pveBtn)
        pveBtn.addTarget(self, action: #selector(didPVEBtnClick), for: .touchUpInside)
        
        /*---------------------------------------------*/
        
        closeBtn.setTitle("Close", for: .normal)
        view.addSubview(closeBtn)
        closeBtn.addTarget(self, action: #selector(closeBtnClick), for: .touchUpInside)
        
        setupForNewGame()
        
        let assemBtn = UIButton.init(frame: CGRect.init(x: 10, y: MXSSize.ScreenSize.height - 44, width: 96, height: 44))
        assemBtn.setTitle("SkillAssem", for: .normal)
        view.addSubview(assemBtn)
        assemBtn.addTarget(self, action: #selector(assemBtnClick), for: .touchUpInside)
        
        let stopBtn = UIButton.init(frame: CGRect.init(x: width*2, y: MXSSize.ScreenSize.height - 40, width: 60, height: 40))
        stopBtn.setTitle("Offline", for: .normal)
        view.addSubview(stopBtn)
        stopBtn.addTarget(self, action: #selector(deviceOffLine), for: .touchUpInside)

        let restartBtn = UIButton.init(frame: CGRect.init(x: stopBtn.frame.maxX+10, y: stopBtn.frame.minY, width: 60, height: 40))
        restartBtn.setTitle("Online", for: .normal)
        view.addSubview(restartBtn)
        restartBtn.addTarget(self, action: #selector(restartBtnClick), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startBrowser()
    }
    
    
    @objc func assemBtnClick() {
        self.present(MXSSkillAssemController(), animated: true) {
            
        }
    }
    @objc func deviceOffLine() {
        stopBrowser()
        MXSNetServ.shared.offLine()
    }
    @objc func restartBtnClick(){
        startBrowser()
    }
    @objc func closeBtnClick() {
        setupForNewGame()
        startBrowser()
    }
        
    override public func startBrowser() {
        if startedBrowser { return }
        
        print("startBrowser")
        servBrowser.delegate = self
        servBrowser.searchForServices(ofType: "_mxs._tcp", inDomain: "local")
        startedBrowser = true
    }
    override public func stopBrowser() {
        print("stopBrowser")
        servBrowser.stop()
        services.removeAll()
        mainTable?.dlg?.dlgData = services
        mainTable?.reloadData()
        
        startedBrowser = false
    }
        
    
    override public func setupForNewGame() {
        
        closeBtn.isHidden = true
    }
    override public func setupForConnected() {
        
    }
    
    
    //MARK: delegate
    func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
        if !MXSNetServ.shared.started {
            MXSNetServ.shared.publishOrRestart()
        }
    }
    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        
    }
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        print("- didFind")
        if !(MXSNetServ.shared.isEqual(service))  {
            services.append(service)
            print("service +1 \n")
        }
        if !moreComing {
            mainTable?.dlg?.dlgData = services
            mainTable?.reloadData()
        }
    }
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        print("- didRemove")
        if !(MXSNetServ.shared.isEqual(service))  {
            services.removeAll { (item) -> Bool in item.isEqual(service) }
        }
        if !moreComing {
            mainTable?.dlg?.dlgData = services
            mainTable?.reloadData()
        }
    }
    
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFindDomain domainString: String, moreComing: Bool) {
        print(domainString)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
