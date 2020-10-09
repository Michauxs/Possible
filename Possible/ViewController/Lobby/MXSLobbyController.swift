//
//  MXSLobbyController.swift
//  Possible
//
//  Created by Sunfei on 2020/9/2.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit

class MXSLobbyController: MXSViewController, NetServiceBrowserDelegate,
    UICollectionViewDelegate,
    UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectData!.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell_c", for: indexPath)
        let select = collectData![indexPath.row]["select"] as! Int
        if select == 1 { cell.backgroundColor = .gray }
        else { cell.backgroundColor = .random }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var item = collectData![indexPath.row]
        let select = item["select"] as! Int
        if select == 1 { item["select"] = 2 }
        else { item["select"] = 1 }

        swap(&item, &collectData![indexPath.row])
        
        let dict = ["selected":indexPath.row]
        MXSNetServ.shared.send(dict)
        mainCollect?.reloadData()
    }
    
    /*---------------------------------------------*/
    @objc func tableDidSelectedRow(args:Array<Any>) {
        let ip:IndexPath = args[1] as! IndexPath
        let server = services[ip.row]
        let success = MXSNetServ.shared.connectToService(server)
        if success {
            stopBrowser()
            mainCollect?.isHidden = false
            closeBtn.isHidden = false
            MXSNetServ.shared.send(["open":1])
        }
    }
    
    func receiveMsg(_ dict:Dictionary<String, Any>) {
        print(dict)
        
        if (dict["open"] != nil) {
            if dict["open"] as! Int == 1 {
                mainCollect?.isHidden = false
                closeBtn.isHidden = false
            }
        }
        
        if (dict["selected"] != nil) {
            let selected_row = dict["selected"] as! Int
            var item = collectData![selected_row]
            let select = item["select"] as! Int
            if select == 1 { item["select"] = 2 }
            else { item["select"] = 1 }
            
            swap(&item, &collectData![selected_row])
            
            mainCollect?.reloadData()
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
    var mainCollect: UICollectionView?
    var collectData: Array<Dictionary<String,Any>>?
    
    @objc func didPVEBtnClick() {
        let vc = MXSGroundController.init()
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true) {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let width = MXSSize.Sw * 0.25
        let textSign = "情深不寿，慧极必伤"
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
        let layout = UICollectionViewFlowLayout.init()
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.itemSize = CGSize.init(width: width*0.5-1, height: width*0.5-1)
        
        mainCollect = UICollectionView.init(frame: CGRect.init(x: 0, y: 0, width: width*2, height: MXSSize.Sh-44), collectionViewLayout: layout)
        view.addSubview(mainCollect!)
        mainCollect?.delegate = self
        mainCollect?.dataSource = self
        mainCollect?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell_c")
        
        collectData = [["select":1],["select":1],["select":1],["select":1],
                       ["select":1],["select":1],["select":1],["select":1],]
        
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
        
    public func startBrowser() {
        if startedBrowser { return }
        
        print("startBrowser")
        servBrowser.delegate = self
        servBrowser.searchForServices(ofType: "_mxs._tcp", inDomain: "local")
        startedBrowser = true
    }
    public func stopBrowser() {
        print("stopBrowser")
        servBrowser.stop()
        services.removeAll()
        mainTable?.reloadData()
        
        startedBrowser = false
    }
        
    
    public func setupForNewGame() {
        mainCollect?.isHidden = true
        closeBtn.isHidden = true
    }
    public func setupForConnected() {
        
    }
    
    
    //MARK: delegate
    func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
        if !MXSNetServ.shared.started {
            MXSNetServ.shared.publishOrRestart()
        }
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        print("didFind")
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
        print("didRemove")
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
