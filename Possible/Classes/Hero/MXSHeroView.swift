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
    
    let contentView :UIView = UIView()
    let lightSign: UIView = UIView()
    
    var portraitImage : UIImageView = UIImageView()
    let nameLabel: UILabel = UILabel.init(text: "", fontSize: 610, textColor: .darkText, align: .center)
    var skillImages : Array<UIImageView> = Array<UIImageView>.init()
    var HPBottle : Array<UIView> = Array<UIView>()
    
    var signStatus:HeroSignStatus = .blank {
        didSet {
            switch signStatus {
            case .active:
                self.lightSign.backgroundColor = .green
            case .selected:
                self.lightSign.backgroundColor = .red
            case .focus:
                self.lightSign.backgroundColor = .yellow
            default:
                self.lightSign.backgroundColor = .clear
            }
        }
    }
    
    weak var controller: MXSViewController? {
        didSet {
            self.isUserInteractionEnabled = true
            self.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(didTapedSelf)))
        }
    }
    @objc func didTapedSelf() {
        if self.belong!.signStatus == .active { return }
        self.controller?.someoneHeroTaped(self)
    }
    
    var HPSum: Int = 0 {
        didSet {
            let heart_width:CGFloat = 12.0
            var count = 0
            let content_width :CGFloat = contentView.bounds.size.width
            while count < HPSum {
                let heart_view = UIView()
                heart_view.layer.cornerRadius = CGFloat(heart_width*0.5)
                heart_view.backgroundColor = .red
                heart_view.alpha = 0.75
                contentView.addSubview(heart_view)
                heart_view.frame = CGRect(x: content_width-5.0-heart_width, y: (heart_width+2.0) * CGFloat(count) + 3.0, width: heart_width, height: heart_width)
                
                HPBottle.append(heart_view)
                count+=1
            }
            HPCurrent = HPSum
        }
    }
    var HPCurrent: Int? = 0 {
        didSet {
            for index in 0...self.HPBottle.count-1 {
                let hp = self.HPBottle[index]
                if index < HPCurrent! {
                    hp.backgroundColor = .red
                }
                else {
                    hp.backgroundColor = .gray
                }
            }
        }
    }
    
    var skillsExp: Array<MXSSkill>? {
        didSet {
            for index in 0..<skillsExp!.count {
                let skill = skillsExp![index]
                let sk_view = skillImages[index]
                sk_view.image = UIImage(named: String(format: "skill_%03d", arguments: [skill.power.rawValue]))
            }
        }
    }
    
    override func setupSubviews() {
        self.bounds = CGRect(x: 0, y: 0, width: MXSSize.Hw, height: MXSSize.Hh)
        
        lightSign.frame = self.bounds
        lightSign.backgroundColor = .clear
        self.addSubview(lightSign)
        
        let padding :CGFloat = 2.0
        let content_width :CGFloat = self.bounds.size.width - padding*2
        let content_height :CGFloat = self.bounds.size.height - padding*2
        contentView.frame = CGRect(x: padding, y: padding, width: content_width, height: content_height)
        contentView.backgroundColor = .cyan
        self.addSubview(contentView)
        
        portraitImage.image = UIImage.init(named: "hero_001")
        portraitImage.contentMode = .scaleAspectFill
        portraitImage.clipsToBounds = true
        contentView.addSubview(portraitImage)
        portraitImage.frame = contentView.bounds
        
        let item_width = content_width * 0.25
        for index in 0...3 {
            let skillView = UIImageView.init(image: UIImage.init(named: "skill_001"))
            skillView.layer.cornerRadius = 0
            skillView.layer.borderWidth = 1;
            skillView.layer.borderColor = UIColor.init(red: 227/255, green: 137/255, blue: 60/255, alpha: 1).cgColor
            contentView.addSubview(skillView)
            skillView.frame = CGRect(x: item_width*CGFloat(index), y: content_height-item_width, width: item_width, height: item_width)
            skillImages.append(skillView)
        }
        
        contentView.addSubview(nameLabel)
        nameLabel.frame = CGRect(x: 0, y: 5, width: 14, height: content_height-item_width)
        
    }
    
    
}
