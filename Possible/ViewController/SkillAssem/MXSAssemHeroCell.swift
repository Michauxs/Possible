//
//  MXSAssemHeroCell.swift
//  Possible
//
//  Created by Sunfei on 2020/9/10.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit

class MXSAssemHeroCell: MXSTableViewCell {
    
    let photoImageView: UIImageView = UIImageView()
    let nameLabel: UILabel = UILabel(text: "Hero Name", fontSize: 315, textColor: .lightText, align: .left)
    var skillViewes: Array<MXSSkillView> = Array<MXSSkillView>()
    
    override func setupUI() {
        super.setupUI()
        
        photoImageView.contentMode = .scaleAspectFill
        addSubview(photoImageView)
        photoImageView.snp.makeConstraints { (m) in
            m.centerY.equalTo(self)
            m.left.equalTo(self).offset(15)
            m.size.equalTo(CGSize(width: 40, height: 50))
        }
        
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (m) in
            m.left.equalTo(photoImageView.snp_right).offset(10)
            m.top.equalTo(photoImageView)
        }
        
        let sk_width: CGFloat = 20.0
        for index in 0...3 {
            let sk_view = MXSSkillView()
            addSubview(sk_view)
            sk_view.snp.makeConstraints { (m) in
                m.left.equalTo(nameLabel).offset((sk_width+2) * CGFloat(index))
                m.bottom.equalTo(photoImageView)
                m.size.equalTo(CGSize(width: sk_width, height: sk_width))
            }
            
            skillViewes.append(sk_view)
        }
    }

    override var cellData: Any? {
        didSet {
            for sk_view in skillViewes { sk_view.unRegisterBelong() }
            
            let info = cellData as! MXSHero
            
            nameLabel.text = info.name
            
            let photo = info.photo
            photoImageView.image = UIImage(named: photo)
            
            for index in 0..<info.skillExp.count {
                let skill = info.skillExp[index]
                let sk_view = skillViewes[index]
                skill.concreteView = sk_view
            }
            
        }
    }
    
}
