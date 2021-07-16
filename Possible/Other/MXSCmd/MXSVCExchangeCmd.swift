//
//  MXSVCExchangeCmd.swift
//  MXSSwift
//
//  Created by Alfred Yang on 14/11/17.
//  Copyright © 2017年 MXS. All rights reserved.
//

import UIKit
import SnapKit
import AVKit

class MXSNothing {
    static let shared = MXSNothing()
}

class MXSVCExchangeCmd: NSObject {
	
	static let shared = MXSVCExchangeCmd()
	
	let keyView = UIApplication.shared.keyWindow
	let halfViewWidth:CGFloat = 243.5
	var moduleSourse : Array<MXSViewController>?
	
	lazy var AnimateLeftView : UIImageView = {
		
		let left_view = UIImageView.init(image: UIImage.init(named: "trans_arrow_left"))
		left_view.tag = 999
		keyView!.addSubview(left_view)
		left_view.frame = CGRect.init(x: -halfViewWidth, y: 0, width: halfViewWidth, height: MXSSize.Sh)
		return left_view
	}()
	lazy var AnimateRightView : UIImageView = {
		
		let right_view = UIImageView.init(image: UIImage.init(named: "trans_arrow_right"))
		right_view.tag = 999
		keyView!.addSubview(right_view)
		right_view.frame = CGRect.init(x: MXSSize.Sw, y: 0, width: halfViewWidth, height: MXSSize.Sh)
		return right_view
	}()
	
	lazy var soundPlayer : AVAudioPlayer = {
		
		let sound = try? AVAudioPlayer.init(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "yinxiao_001", ofType: "mp3")!))
		
		return sound!
	}()
	
	func SourseVCPushDestVC(sourse:MXSViewController, dest:MXSViewController, args:Any) {
//		if !(args === MXSNothing.shared) {
//        }
        dest.receiveArgsBePost(args: args)
		
		AnimateRightView.isHidden = false
		AnimateLeftView.isHidden = false
		
//        self.soundPlayer.play()
		UIView.animate(withDuration: 0.35, animations: {
			self.AnimateLeftView.frame = CGRect.init(x: 0, y: 0, width: self.halfViewWidth, height: MXSSize.Sh)
			self.AnimateRightView.frame = CGRect.init(x: MXSSize.Sw-self.halfViewWidth, y: 0, width: self.halfViewWidth, height: MXSSize.Sh)
		}) { (complete) in
			
			dest.hidesBottomBarWhenPushed = true
			sourse.navigationController?.pushViewController(dest, animated: false)
			
			DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
				UIView.animate(withDuration: 0.35, animations: {
					self.AnimateLeftView.frame = CGRect.init(x: -self.halfViewWidth, y: 0, width: self.halfViewWidth, height: MXSSize.Sh)
					self.AnimateRightView.frame = CGRect.init(x: MXSSize.Sw, y: 0, width: self.halfViewWidth, height: MXSSize.Sh)
				}) {(complete) in
					self.AnimateRightView.isHidden = true
					self.AnimateLeftView.isHidden = true
				}
			})
		}
	}
	
	func SourseVCPop (sourse:MXSViewController, args:Any) {
		self.AnimateRightView.isHidden = false
		self.AnimateLeftView.isHidden = false
		
//        self.soundPlayer.play()
		UIView.animate(withDuration: 0.35, animations: {
			self.AnimateLeftView.frame = CGRect.init(x: 0, y: 0, width: self.halfViewWidth, height: MXSSize.Sh)
			self.AnimateRightView.frame = CGRect.init(x: MXSSize.Sw-self.halfViewWidth, y: 0, width: self.halfViewWidth, height: MXSSize.Sh)
		}) { (complete) in
			
			let nav = sourse.navigationController
			nav?.popViewController(animated: false)
			let pop = nav?.viewControllers.last as! MXSViewController
//			if !(args === MXSNothing.shared) {
//            }
            pop.receiveArgsBeBack(args:args)
			
			DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
				UIView.animate(withDuration: 0.35, animations: {
					self.AnimateLeftView.frame = CGRect.init(x: -self.halfViewWidth, y: 0, width: self.halfViewWidth, height: MXSSize.Sh)
					self.AnimateRightView.frame = CGRect.init(x: MXSSize.Sw, y: 0, width: self.halfViewWidth, height: MXSSize.Sh)
				}) {(complete) in
					self.AnimateRightView.isHidden = true
					self.AnimateLeftView.isHidden = true
				}
			})
		}
		
	}
	
	func SourseVCPopToDest(sourse:MXSViewController, dest:MXSViewController, args:Any) {
		for vc in (sourse.navigationController?.viewControllers)! {
			if vc.isKind(of: object_getClass(dest)!) {
				
				sourse.navigationController?.popToViewController(vc, animated: true)
				
                (vc as! MXSViewController).receiveArgsBeBack(args:args)
			}
		}
	}
	func SourseVCPopToRoot(sourse:MXSViewController, args:Any) {
		sourse.navigationController?.popToRootViewController(animated: true)
		let pop = sourse.navigationController?.viewControllers.last as! MXSViewController
        
        pop.receiveArgsBeBack(args:args)
	}
	
	//MARK: module
	public func PresentVC(_ sourse:MXSViewController, dest:MXSViewController, args:Any) {
//		if !(args === MXSNothing.shared) {
//        }
        dest.receiveArgsBePost(args:args)
        if moduleSourse == nil {
            moduleSourse = Array.init()
        }
        let moduleVC = sourse.navigationController?.viewControllers.last as? MXSViewController
        moduleSourse?.append(moduleVC!)
        dest.modalPresentationStyle = .overFullScreen
		sourse.navigationController?.present(dest, animated: true, completion: {
			
		})
	}
	public func DismissVC (_ vc:MXSViewController, args:Any) {
        let moduleVC = moduleSourse?.last
		vc.dismiss(animated: true) {
            self.moduleSourse?.removeLast()
			moduleVC?.receiveArgsBeBack(args:args)
		}
	}
	
	//		var count: UInt32 = 0
	//		let methods = class_copyMethodList(MXSTableView.self, &count)
	//
	//		for i in 0...count-1 {
	//			let method = methods![Int(i)]
	//			let sel = method_getName(method)
	//			let methodName = sel_getName(sel)
	//			let argument = method_getNumberOfArguments(method)
	//
	//			print("name: \(methodName), arguemtns: \(argument)")
	//		}
}
