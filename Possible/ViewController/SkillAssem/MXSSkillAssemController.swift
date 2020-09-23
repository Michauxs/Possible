//
//  MXSSkillAssembleController.swift
//  Possible
//
//  Created by Sunfei on 2020/9/4.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit

class MXSSkillAssemController: MXSViewController {

    var mainTable: MXSTableView?
    var mainCollection: MXSCollectionView?
    
    let nameLabel:UILabel = UILabel.init(text: "Name", fontSize: 316, textColor: .white, align: .left)
    var skillViewes: Array<MXSSkillView> = Array<MXSSkillView>()
    
    var heroMark: MXSHero?
    var skillViewAsseming: MXSSkillView?
    var skillMarkArray: Array<String> = Array<String> ()
    
    @objc func didCloseGameBtnClick() {
        self.dismiss(animated: true) {
            
        }
    }
    @objc func didDoneBtnClick() {
        var tmp = Array<String>()
        for uu in skillMarkArray {
            tmp.append(uu)
        }
        
        heroMark!.exchangeSkillExp(marks: tmp)
        mainTable?.reloadData()
        
        UserDefaults.standard.setValue(tmp, forKey: heroMark!.photo)
        
        let alert = UIAlertController.init(title: "title", message: "done", preferredStyle: .alert)
        let action = UIAlertAction.init(title: "get", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width_hero = MXSSize.Sw * 0.25
        let width_assem = MXSSize.Sw * 0.45
        let width_skill = MXSSize.Sw * 0.3
        
        let top_height: CGFloat = 44.0
        let topView = UIView.init()
        topView.backgroundColor = UIColor.init(75, 80, 100)
        topView.frame = CGRect.init(x: 0, y: 0, width: MXSSize.Sw, height: top_height)
        self.view.addSubview(topView)
        
        let pveBtn = UIButton.init("Close", fontSize: 14, textColor: .white, backgColor: .darkGray)
        pveBtn.frame = CGRect.init(x: 10, y: 0, width: 64, height: top_height)
        self.view.addSubview(pveBtn)
        pveBtn.addTarget(self, action: #selector(didCloseGameBtnClick), for: .touchUpInside)
        
        mainTable = MXSTableView.init(frame: CGRect(x: 0, y: top_height, width: width_hero, height: MXSSize.Sh-top_height), style: .plain)
        self.view.addSubview(mainTable!)
        mainTable?.register(cellNames: ["MXSAssemHeroCell"], delegate: MXSTableDlg(), vc: self, rowHeight: 64)
        
        mainTable?.dlg!.dlgData = MXSHeroCmd.shared.allHeroModel()
        /*--------------------------------------*/
        let inset:CGFloat = 10.0
        mainCollection = MXSCollectionView.init(frame: CGRect(x: MXSSize.Sw-width_skill, y: top_height, width: width_skill, height: mainTable!.frame.height), layout: nil, spacing: [5.0, 7.0])
        self.view.addSubview(mainCollection!)
        let item_w = (width_skill - 5.0*2 - inset*2 - 2.0) / 3
        mainCollection?.register(cellNames: ["MXSAssemSkillItem"], delegate: MXSCollectionDlg(), vc: self, itemSize: CGSize(width: item_w, height: item_w+15))
        mainCollection?.contentInset = UIEdgeInsets.init(top: inset, left: inset, bottom: inset, right: inset)
        mainCollection?.dlg!.dlgData = MXSSkillCmd.shared.arrayModelData()
        /*--------------------------------------*/
        
        let removeBtn = UIButton.init("Remove", fontSize: 14, textColor: .white, backgColor: .darkGray)
        removeBtn.frame = CGRect.init(x: mainTable!.frame.maxX + 20, y: MXSSize.Sh - top_height - 20, width: 64, height: top_height)
        self.view.addSubview(removeBtn)
        removeBtn.addTarget(self, action: #selector(didRemoveBtnClick), for: .touchUpInside)
        
        let doneBtn = UIButton.init("Done", fontSize: 14, textColor: .white, backgColor: .darkGray)
        doneBtn.frame = CGRect.init(x: mainCollection!.frame.minX - 84, y: MXSSize.Sh - top_height - 20, width: 64, height: top_height)
        self.view.addSubview(doneBtn)
        doneBtn.addTarget(self, action: #selector(didDoneBtnClick), for: .touchUpInside)
        /*--------------------------------------*/
        view.addSubview(nameLabel)
        nameLabel.frame = CGRect(x: mainTable!.frame.maxX+15, y: top_height+15, width: 100, height: 20)
        
        let centerPoint:CGPoint = CGPoint(x: width_hero + width_assem*0.5, y: MXSSize.Sh*0.5)
        let sk_width: CGFloat = 44.0
        for index in 0...3 {
            let sk_view = MXSSkillView()
            sk_view.tag = index
            sk_view.controller = self
            let skill = MXSSkillCmd.shared.getBlankSkill()
            skill.concreteView = sk_view
            self.view.addSubview(sk_view)
            let x = CGFloat(cos(Double.pi/2 * Double(index)))
            let y = CGFloat(sin(Double.pi/2 * Double(index)))
            sk_view.bounds = CGRect.init(x: 0, y: 0, width: sk_width, height: sk_width)
            sk_view.center = CGPoint(x: centerPoint.x - (sk_width+20.0)*x, y: centerPoint.y - (sk_width+20.0)*y)
            skillViewes.append(sk_view)
        }
        
        /**initional*/
        fillSkillView(hero: mainTable?.dlg!.dlgData!.first as? MXSHero)
    }
    
    func fillSkillView(hero:MXSHero?) {
        if hero == nil { return }
        
        heroMark = hero
        nameLabel.text = hero!.name
        skillMarkArray.removeAll()
        
        for index in 0..<skillViewes.count {
            let sk_view = skillViewes[index]
            sk_view.unRegisterBelong()
            
            if hero!.skillExp.count > index {
                let skill = hero!.skillExp[index]
                skill.concreteView = sk_view
                skillMarkArray.append(skill.photo!)
            }
            else { skillMarkArray.append(SkillBlankPhoto) }
        }
    }
    
    @objc func someoneSkillViewTaped(_ skillView:MXSSkillView) {
        if skillView.assemOn {
            skillViewAsseming?.assemOn = false
            skillViewAsseming = skillView
        }
        else { skillViewAsseming = nil }
        
    }
    
    @objc func tableDidSelectedRow(args:Array<Any>) {
        skillViewAsseming?.assemOn = false
        skillViewAsseming = nil
        
        let ip:IndexPath = args[1] as! IndexPath
        fillSkillView(hero: mainTable?.dlg!.dlgData![ip.row] as? MXSHero)
    }

    @objc func collectionDidSelectedItem(args:Array<Any>) {
        if skillViewAsseming == nil { return }
        
        let ip:IndexPath = args[1] as! IndexPath
        let uu = mainCollection!.dlg?.dlgData![ip.item] as! String
        
        skillMarkArray[skillViewAsseming!.tag] = uu
        
        let skill = MXSSkillCmd.shared.getSkillFromUUMark(uu)
        skill.concreteView = skillViewAsseming
        skillViewAsseming?.assemOn = false
        skillViewAsseming = nil
    }
    
    @objc func didRemoveBtnClick() {
        if skillViewAsseming == nil { return }
        
        let skill_blank = MXSSkillCmd.shared.getBlankSkill()
        skillMarkArray[skillViewAsseming!.tag] = skill_blank.photo!
        skill_blank.concreteView = skillViewAsseming
    }
    
}
