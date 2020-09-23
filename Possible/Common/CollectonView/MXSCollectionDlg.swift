//
//  MXSCollectionDlg.swift
//  MXSSwift
//
//  Created by Alfred Yang on 27/11/17.
//  Copyright © 2017年 MXS. All rights reserved.
//

import UIKit

class MXSCollectionDlg: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	var dlgData : Array<Any>?
	var itemSize : CGSize?
	var cellNames : Array<String>?
	var controller : MXSViewController?
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if dlgData != nil {
			return (dlgData?.count)!
		} else {
			return 0
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:MXSCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellNames!.first!, for: indexPath) as! MXSCollectionCell
		cell.cellData = dlgData?[indexPath.row]
		return cell
	}
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return itemSize!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var info = Array<Any>.init()
        info.append(collectionView)
        info.append(indexPath)
        self.controller?.perform(NSSelectorFromString("collectionDidSelectedItemWithArgs:"), with: info)
    }
//
//
//	//MARK:scrollview
//	func scrollViewDidScroll(_ scrollView: UIScrollView) {
//		let offset_y = scrollView.contentOffset.y
//		controller?.tableDidScroll(offset_y: offset_y)
//	}
	
}
