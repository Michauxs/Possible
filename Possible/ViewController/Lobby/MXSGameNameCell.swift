//
//  MXSGameNameCell.swift
//  Possible
//
//  Created by Sunfei on 2025/3/28.
//  Copyright © 2025 boyuan. All rights reserved.
//

import UIKit

class MXSGameNameCell: MXSTableViewCell {
    
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
            let serv = cellData as! String
            titleLabel.text = serv
        }
    }

}
