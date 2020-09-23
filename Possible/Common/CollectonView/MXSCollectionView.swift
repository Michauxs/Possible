//
//  MXSCollectionView.swift
//  MXSSwift
//
//  Created by Alfred Yang on 27/11/17.
//  Copyright © 2017年 MXS. All rights reserved.
//

import UIKit

class MXSCollectionView: UICollectionView {

	var dlg : MXSCollectionDlg?

    convenience init(frame:CGRect, layout:UICollectionViewLayout?, spacing:Array<CGFloat>) {
        
        if layout == nil {
            let layout_new = UICollectionViewFlowLayout.init()
            layout_new.minimumInteritemSpacing = spacing[0]
            layout_new.minimumLineSpacing = spacing[1]
            self.init(frame: frame, collectionViewLayout: layout_new)
        }
        else {
            self.init(frame: frame, collectionViewLayout: layout)
        }
    }
    
	override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout?) {
        var lay: UICollectionViewLayout? = layout
        if lay == nil {
            lay = UICollectionViewFlowLayout.init()
            (lay as! UICollectionViewFlowLayout).minimumLineSpacing = 1
            (lay as! UICollectionViewFlowLayout).minimumInteritemSpacing = 1
        }
        
        super.init(frame: frame, collectionViewLayout: lay!)
		showsVerticalScrollIndicator = false
		showsHorizontalScrollIndicator = false
	}
    
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public func register(cellNames:Array<String>, delegate:MXSCollectionDlg, vc:MXSViewController, itemSize:CGSize = CGSize.zero) {
		
        let namespace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
        for cellName in cellNames {
            let cellClass : AnyClass = NSClassFromString(namespace + "." + cellName)!
            register(cellClass, forCellWithReuseIdentifier: cellName)
        }
		
		dlg = delegate
		self.delegate = dlg
		self.dataSource = dlg
		dlg?.controller = vc
		dlg?.cellNames = cellNames
		
		if !itemSize.equalTo(CGSize.zero) {
			dlg?.itemSize = itemSize
		}
		
		// 告诉编译器它的真实类型
//		let viewControllerClass = cellClass as! UIViewController.Type
//		let viewController = viewControllerClass.init()
	}
}
