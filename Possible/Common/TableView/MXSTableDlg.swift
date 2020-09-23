//
//  MXSTableDlg.swift
//  MXSSwift
//
//  Created by Alfred Yang on 14/11/17.
//  Copyright © 2017年 MXS. All rights reserved.
//

import UIKit

/*
*	子类注意事项：
		1.注册/获取cell都是通过 具体cell类的String，不能使用通用cell基类的名字String， 必须独自实现 cellForRowAt；
		2.自动高度UITableViewAutomaticDimension的cell 不能再实现heightForRowAt，所以此方法交由子类自行实现；
*/
class MXSTableDlg: NSObject, UITableViewDelegate, UITableViewDataSource {
	
	var dlgData : Array<Any>?
	var cellNames : Array<String>?
	var controller : MXSViewController?
    var rowHeight: CGFloat = 44.0
	
	func changeData(data:Array<Any>) {
		dlgData = data
	}
	
    //MARK:=dataSourse
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (dlgData != nil) ? (dlgData?.count)! : 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MXSTableViewCell = tableView.dequeueReusableCell(withIdentifier: (cellNames?.first)!, for: indexPath) as! MXSTableViewCell
        cell.cellData = dlgData?[indexPath.row]
		return cell
	}
	
    //MARK:=delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var info = Array<Any>.init()
        info.append(tableView)
        info.append(indexPath)
        self.controller?.perform(NSSelectorFromString("tableDidSelectedRowWithArgs:"), with: info)
	}
	
	
    
    //MARK:=delegate -other
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return false
	}
	
	func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
		return "Delete"
	}
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        var info = Dictionary<String, Any>.init(minimumCapacity: 2)
        info["indexPath"] = indexPath
        info["tableView"] = tableView
        self.controller?.perform(NSSelectorFromString("tableDidDeletedRowWithArgs:"), with: info)
	}
	
    
    
    
	//MARK:=delegate -scrollview
//	func scrollViewDidScroll(_ scrollView: UIScrollView) {
//		let offset_y = scrollView.contentOffset.y
//		controller?.tableDidScroll(offset_y: offset_y)
//	}
}
