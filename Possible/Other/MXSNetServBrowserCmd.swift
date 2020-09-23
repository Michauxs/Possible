//
//  MXSNetServiceCmd.swift
//  Possible
//
//  Created by Sunfei on 2020/9/1.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit


class MXSNetServBrowserCmd: NSObject, NetServiceBrowserDelegate {
    
    let serviceType: String = "_mxs._tcp"
    let serviceDomain: String = "local"
    
    weak var belong: MXSViewController?
    var servBrowser: NetServiceBrowser?
    var services: Array<NetService> = Array<NetService>.init()
    var localServ: NetService?
    
    static let shared : MXSNetServBrowserCmd = {
        let single = MXSNetServBrowserCmd.init()
        return single
    }()
    
    public func start() {
        servBrowser = NetServiceBrowser.init()
        servBrowser?.includesPeerToPeer = true
        servBrowser?.delegate = self
        servBrowser?.searchForServices(ofType: serviceType, inDomain: serviceDomain)
    }
    
    public func stop() {
        servBrowser?.stop()
        servBrowser = nil
        services.removeAll()
    }
    
    
    //MARK: delegate
    func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
        print("netServiceBrowserWillSearch")
    }
    
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        if !(localServ?.isEqual(service) ?? false)  {
            services.append(service)
        }
        if !moreComing {
//            let _ = belong?.perform(Selector.init(("servicesHasChanged:")), with: services)?.takeUnretainedValue()
//            belong?.perform(NSSelectorFromString("servicesHasChanged:"), with: services)
            belong?.perform(Selector("servicesHasChanged:"), with: services)
        }
    }
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        if !(localServ?.isEqual(service) ?? false)  {
            services.removeAll(where: {$0 === service})
        }
        if !moreComing {
            belong?.perform(NSSelectorFromString("servicesHasChanged:"), with: services)
        }
    }
    
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFindDomain domainString: String, moreComing: Bool) {
        print(domainString)
    }
    
}
