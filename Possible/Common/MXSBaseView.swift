//
//  MXSBaseView.swift
//  Possible
//
//  Created by Sunfei on 2020/8/19.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit

class MXSBaseView: UIView {
//    weak var belong:MXSGroundController?
    weak var control:MXSViewController?
    var info: Any?
    
    var responHandler: ((_ meth:String, _ args:Dictionary<String,Any>) -> Dictionary<String,Any>)?
    var responder: ((_ meth:String, _ args:Dictionary<String,Any>) -> Void)?
    
    convenience init(control :MXSViewController) {
        self.init()
        self.control = control;
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    
    open func setupSubviews() {
                
    }

    /**-----------------------------**/
    func setUserInteraction() {
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selfTaped)))
    }
    @objc func selfTaped() {
//        self.control?.callFunction(byName: <#T##String#>, withPara: <#T##Any#>)
    }
    
    
}
