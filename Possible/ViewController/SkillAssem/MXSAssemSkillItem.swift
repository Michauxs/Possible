//
//  MXSAssemSkillItem.swift
//  Possible
//
//  Created by Sunfei on 2020/9/11.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit

class MXSAssemSkillItem: MXSCollectionCell {
    
    let photoImageView: UIImageView = UIImageView()
    let nameLabel: UILabel = UILabel(text: "Skill", fontSize: 313, textColor: .lightText, align: .center)
    
    override func setupUI() {
        
        photoImageView.contentMode = .scaleAspectFill
        addSubview(photoImageView)
        photoImageView.snp.makeConstraints { (m) in
            m.edges.equalTo(self).inset(UIEdgeInsets.init(top: 0, left: 0, bottom: 15, right: 0))
        }
        photoImageView.setRaius(0.5, borderColor: .theme, borderWitdh: 1)
        
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (m) in
            m.left.equalTo(self)
            m.right.equalTo(self)
            m.top.equalTo(photoImageView.snp_bottom)
        }
        
    }
    
    
    override var cellData: Any? {
        didSet {
            let uu = cellData as! String
            
            let skill = MXSSkillCmd.shared.getSkillFromUUMark(uu)
            nameLabel.text = skill.name
            
            let photo = skill.photo!
            photoImageView.image = UIImage(named: photo)
            
        }
    }
    
}
