//
//  MXSTableViewCell.swift
//  MXSSwift
//
//  Created by Alfred Yang on 24/11/17.
//  Copyright © 2017年 MXS. All rights reserved.
//

import UIKit

class MXSTableViewCell: UITableViewCell {

    var SepBtmLine : UIView?
    var SepBtmLine2 : UIView?
    
	var cellData : Any? {
		didSet {
			
		}
	}
    
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		backgroundColor = UIColor.lightBlack
		selectionStyle = .none
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:actions
    public func setupUI() {
        drawBtmLine()
        
    }
    
	public func drawBtmLine() {
		SepBtmLine = UIView.init()
        addSubview(SepBtmLine!)
		SepBtmLine!.backgroundColor = UIColor.darkLine
		SepBtmLine!.snp.makeConstraints { (make) in
			make.right.equalTo(self)
			make.left.equalTo(self).offset(15)
			make.bottom.equalTo(self)
			make.height.equalTo(0.5)
		}
		SepBtmLine2 = UIView.init()
		addSubview(SepBtmLine2!)
		SepBtmLine2!.backgroundColor = UIColor.black
		SepBtmLine2!.snp.makeConstraints { (make) in
			make.right.equalTo(self)
			make.left.equalTo(self).offset(15)
			make.bottom.equalTo(self).offset(-0.5)
			make.height.equalTo(0.5)
		}
	}
}
