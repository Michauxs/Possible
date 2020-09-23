//
//  MXSSkillView.swift
//  Possible
//
//  Created by Sunfei on 2020/9/10.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit

class MXSSkillView: MXSBaseView {
    weak var belong: MXSSkill?
    weak var controller: MXSViewController? {
        didSet {
            self.isUserInteractionEnabled = true
            self.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(didTapedSelf)))
        }
    }
    
    let imageView: UIImageView = UIImageView()
    var powerPhoto: SkillPower? {
        didSet {
            imageView.image = UIImage(named: String(format: "skill_%03d", arguments: [powerPhoto!.rawValue]))
        }
    }
    var photo: String? {
        didSet {
            imageView.image = UIImage(named: photo!)
        }
    }
    
    let lightView: UIView = UIView()
    var assemOn: Bool = false {
        didSet {
            lightView.isHidden = !assemOn
        }
    }
    
    override func setupSubviews() {
        
        imageView.image = UIImage(named: "skill_000")
        addSubview(imageView)
        imageView.snp.makeConstraints { (m) in
            m.edges.equalTo(self)
        }
        
        lightView.backgroundColor = .alphaWhite
        addSubview(lightView)
        lightView.snp.makeConstraints { (m) in
            m.edges.equalTo(self);
        }
        lightView.isHidden = true
        
        
        self.setRaius(0.5, borderColor: .brown, borderWitdh: 0.5)
    }

    @objc func didTapedSelf() {
        self.assemOn = !self.assemOn
        self.controller?.perform(Selector(("someoneSkillViewTaped:")), with: self)
    }
    
    
    func unRegisterBelong() {
        imageView.image = UIImage(named: String(format: "skill_%03d", arguments: [SkillPower.blank.rawValue]))
        self.belong = nil
    }
    
}
