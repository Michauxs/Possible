//
//  MXSDeviceCell.swift
//  Possible
//
//  Created by Sunfei on 2020/9/23.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit

class MXSDeviceCell: MXSTableViewCell {

    let titleLabel:UILabel = UILabel.init(text: "", fontSize: 314, textColor: .gray, align: .left)
    
    override func setupUI() {
        super.setupUI()
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (m) in
            m.left.equalTo(self).offset(15)
            m.centerY.equalTo(self)
        }
    }
    
    override var cellData: Any? {
        didSet {
            let serv = cellData as! NetService
            titleLabel.text = serv.name
        }
    }

}
