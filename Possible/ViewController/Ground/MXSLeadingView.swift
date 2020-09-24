//
//  MXSLeadingView.swift
//  Possible
//
//  Created by Sunfei on 2020/8/31.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit

/**操作按钮群集*/
enum LeadingState : Int {
    case attackUnPick
    case attackPicked
    case attackReadyOn
    case defenseUnPick
    case defensePicked
    case defenseReadyOn
}

/**
enum LeadingState {
enum attack {
case picked
case readyOn
case unPick
}
enum defense {
case picked
case readyOn
case unPick
}
}
*/

class MXSLeadingView: MXSBaseView {
    weak var belong:MXSGroundController?
    
    var cancelBtn: UIButton?
    var certainBtn: UIButton?
    var state: LeadingState! {
        didSet {
            switch state {
            case .attackUnPick:
                certainBtn?.isEnabled = false
                cancelBtn?.isSelected = true
            case .attackPicked, .defenseUnPick, .defensePicked:
                certainBtn?.isEnabled = false
                cancelBtn?.isSelected = false
            case .attackReadyOn, .defenseReadyOn:
                certainBtn?.isEnabled = true
                cancelBtn?.isSelected = false
                
            case .none:
                certainBtn?.isEnabled = false
                cancelBtn?.isSelected = false
            }
        }
        
    }
    
    override func setupSubviews() {
        
        certainBtn = UIButton.init("确定", fontSize: 614, textColor: .white)
        certainBtn?.setTitleColor(.gray, for: .disabled)
        certainBtn?.setRaius(3.0, borderColor: .white, borderWitdh: 0.5)
        certainBtn!.addTarget(self, action: #selector(didCertainBtnClick), for: .touchUpInside)
        self.addSubview(certainBtn!)
        certainBtn!.snp.makeConstraints { (m) in
            m.center.equalTo(self)
            m.size.equalTo(CGSize.init(width: 64, height: 38))
        }
        certainBtn?.isEnabled = false
        
        /*--------------------------------------------*/
        cancelBtn = UIButton.init("取消", fontSize: 614, textColor: .white)
        cancelBtn!.setTitle("结束", for: .selected)
        cancelBtn!.setRaius(3.0, borderColor: .white, borderWitdh: 0.5)
        cancelBtn!.addTarget(self, action: #selector(didCancelBtnClick), for: .touchUpInside)
        self.addSubview(cancelBtn!)
        cancelBtn!.snp.makeConstraints { (m) in
            m.centerY.equalTo(self)
            m.left.equalTo(certainBtn!.snp.right).offset(30)
            m.size.equalTo(certainBtn!)
        }
    }

    
    //MARK: actions
    @objc func didCertainBtnClick () {
        if self.state == LeadingState.attackReadyOn {
            print("certainAttackAction")
            self.belong?.certainForAttack()
        }
        else if self.state == LeadingState.defenseReadyOn {
            print("respondAttack")
            self.belong?.certainForDefense()
        }
    }
        
    @objc func didCancelBtnClick (btn:UIButton) {
        if self.state == LeadingState.attackUnPick {
            print("endActiveAction")
            self.belong?.endActive()
        }
        else if self.state == LeadingState.attackPicked || self.state == LeadingState.attackReadyOn{
            print("cancel Pickes")
            self.belong?.cancelPickes()
            self.state = LeadingState.attackUnPick
        }
            
        else if self.state == LeadingState.defenseUnPick || self.state == LeadingState.defensePicked || self.state == LeadingState.defenseReadyOn{
            print("unRespond Attack")
            self.belong?.cancelForDefense()
        }
    }
    
    
}
