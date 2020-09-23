//
//  MXSHeroRoleView.swift
//  Possible
//
//  Created by Sunfei on 2020/8/14.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit
import SnapKit

class MXSHeroView: MXSBaseView {
    weak var belong:MXSHero?
    
    var portraitImage : UIImageView?
    var nameLabel: UILabel?
    var skillImages : Array<UIImageView>?
    
    var HPBottle : Array<UIView>?
    
    public lazy var lightSign: UIView = {
        var sign = UIView.init()
        sign.backgroundColor = .white
        sign.frame = CGRect.init(x: 10, y: 10, width: 10, height: 10)
        self.addSubview(sign)
        return sign
    }()
    /**被选择*/
    var isSelected: Bool? = false {
        didSet {
            self.lightSign.backgroundColor = .yellow
            self.lightSign.isHidden = !isSelected!
        }
    }
    /**在等待对方*/
    var isHoldOn: Bool? = false {
        didSet {
            self.lightSign.backgroundColor = .green
            self.lightSign.isHidden = !isHoldOn!
        }
    }
    
    weak var controller: MXSViewController? {
        didSet {
            self.isUserInteractionEnabled = true
            self.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(didTapedSelf)))
        }
    }
    @objc func didTapedSelf() {
        if self.belong!.isActive { return }
        self.controller?.someoneHeroTaped(self)
    }
    
    var LP: Int? = 0 {
        didSet {
            HPBottle = Array.init()
            let heart_width = 12.0
            var count = 0
            while count < LP! {
                let skillView = UIView()
                skillView.layer.cornerRadius = CGFloat(heart_width*0.5)
                skillView.backgroundColor = .red
                skillView.alpha = 0.75
                self.addSubview(skillView)
                skillView.snp.makeConstraints { (make) in
                    make.top.equalTo(self).offset((heart_width+2.0) * Double(count) + 3)
                    make.right.equalTo(self).inset(5)
                    make.size.equalTo(CGSize.init(width: heart_width, height: heart_width))
                }
                HPBottle!.append(skillView)
                count+=1
            }
            hp = LP
        }
    }
    var hp: Int? = 0 {
        didSet {
            for index in 0...self.HPBottle!.count-1 {
                let h = self.HPBottle![index]
                if index < hp! {
                    h.backgroundColor = .red
                }
                else {
                    h.backgroundColor = .gray
                }
            }
        }
    }
    
    var skillsExp: Array<MXSSkill>? {
        didSet {
            for index in 0..<skillsExp!.count {
                let skill = skillsExp![index]
                let sk_view = skillImages![index]
                sk_view.image = UIImage(named: String(format: "skill_%03d", arguments: [skill.power.rawValue]))
            }
        }
    }
    
    override func setupSubviews() {
        backgroundColor = .cyan
        self.bounds = CGRect.init(x: 0, y: 0, width: MXSSize.Hw, height: MXSSize.Hh)
        clipsToBounds = true
        
        portraitImage = UIImageView.init(image: UIImage.init(named: "hero_001"))
        portraitImage?.contentMode = .scaleAspectFill
        self.addSubview(portraitImage!)
        portraitImage?.snp.makeConstraints({ (make) in
            make.edges.equalTo(self).inset(UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0))
        })
        
        skillImages = Array.init()
        let item_width = self.bounds.size.width * 0.25
        for index in 0...3 {
            let skillView = UIImageView.init(image: UIImage.init(named: "skill_001"))
            skillView.layer.cornerRadius = 0
            skillView.layer.borderWidth = 1;
            skillView.layer.borderColor = UIColor.init(red: 227/255, green: 137/255, blue: 60/255, alpha: 1).cgColor
            self.addSubview(skillView)
            skillView.snp.makeConstraints { (make) in
                make.left.equalTo(self).offset(item_width*CGFloat(index))
                make.bottom.equalTo(self)
                make.size.equalTo(CGSize.init(width: item_width, height: item_width))
            }
            skillImages?.append(skillView)
        }
        
        nameLabel = UILabel.init()
        nameLabel?.textColor = .darkText
        nameLabel?.numberOfLines = 0
        nameLabel?.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        addSubview(nameLabel!)
        nameLabel?.snp.makeConstraints({ (m) in
            m.left.equalTo(self).offset(5)
            m.top.equalTo(self).offset(5)
            m.width.equalTo(12)
        })
        
    }
    
}
