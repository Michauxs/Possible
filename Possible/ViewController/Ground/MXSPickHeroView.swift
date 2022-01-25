//
//  MXSPickHeroView.swift
//  Possible
//
//  Created by Sunfei on 2020/9/24.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit

class MXSHeroShowView: MXSBaseView {
    
    let photoView:UIImageView = UIImageView()
    var photo:String? {
        didSet {
            photoView.image = UIImage(named: photo!)
        }
    }
    let nameLabel:UILabel = UILabel(text: "***", fontSize: 314, textColor: .white, align: .center)
    var name:String? {
        didSet {
            nameLabel.text = name
        }
    }
    
    let selectSign:UILabel = UILabel(text: "选", fontSize: 1018, textColor: .white, align: .center)
    var isSelect:Bool = false {
        didSet {
            selectSign.isHidden = !isSelect
        }
    }
    
    override func setupSubviews() {
        photoView.contentMode = .scaleAspectFill
        photoView.clipsToBounds = true
        addSubview(photoView)
        photoView.snp.makeConstraints { (m) in
            m.edges.equalTo(self)
        }
        
        nameLabel.backgroundColor = UIColor.init(white: 0, alpha: 0.75)
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (m) in
            m.bottom.equalTo(self).inset(5)
            m.left.equalTo(self)
            m.right.equalTo(self)
            m.height.equalTo(20)
        }
        
        let wh:CGFloat = 28.0
        selectSign.backgroundColor = .red
        addSubview(selectSign)
        selectSign.snp.makeConstraints { (m) in
            m.center.equalTo(self)
            m.size.equalTo(CGSize(width: wh, height: wh))
        }
        selectSign.setRaius(wh*0.5, borderColor: .orange, borderWitdh: 1.0)
        selectSign.isHidden = true
        
        self.setRaius(2.0, borderColor: .gray, borderWitdh: 0.5)
    }
}

class MXSPickHeroView: MXSBaseView {
    weak var belong:MXSGroundController?
    var pickType:PickHeroType = .PVE
    
    var pickedCount:Int = 0
    let hero_width:CGFloat = 80.0
    let hero_height:CGFloat = 120.0
    let between:CGFloat = 3.0
    let numb_col = 4
    let contentView = UIView()
    let tipsLabel:UILabel = UILabel.init(text: "", fontSize: 314, textColor: .gray, align: .left)
    var conctectViewes:Array<MXSHeroShowView> = Array<MXSHeroShowView>()
    var heroData:Array<MXSHero>? {
        didSet {
            guard heroData != nil else {
                return
            }
            let content_width:CGFloat = hero_width * CGFloat(numb_col) + between * CGFloat(numb_col-1)
            let padding_left:CGFloat = (self.frame.width - content_width) * 0.5
            for index in 0 ..< heroData!.count {
                let row = index/numb_col
                let col = index%numb_col
                let view = MXSHeroShowView()
                view.frame = CGRect(x: padding_left + (hero_width+between)*CGFloat(col), y: (hero_height+between)*CGFloat(row), width: hero_width, height: hero_height)
                view.tag = index
                contentView.addSubview(view)
                conctectViewes.append(view)
                
                let hero = heroData![index]
                view.photo = hero.photo
                view.name = hero.name
                
                view.isUserInteractionEnabled = true
                view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(didTapedSelf(taped:))))
                
            }
            
            contentView.addSubview( tipsLabel)
            tipsLabel.snp.makeConstraints { make in
                make.left.equalTo(contentView).offset(padding_left*0.5)
                make.top.equalTo(contentView).offset(20)
                make.width.equalTo(20)
            }
            tipsLabel.text = "请选择主体"
        }
    }
    
    override func setupSubviews() {
        let maskView = UIView()
        maskView.backgroundColor = UIColor.init(white: 0, alpha: 0.75)
        maskView.frame = self.bounds
        addSubview(maskView)
        
        let content_height:CGFloat = hero_height * 2 + between
        
        let padding:CGFloat = (self.frame.height - content_height) * 0.5
        
        contentView.backgroundColor = .black
        addSubview(contentView)
        contentView.frame = CGRect(x: 0, y: padding, width: self.frame.width, height: content_height)
        
    }

    @objc func didTapedSelf(taped:UITapGestureRecognizer) {
        let view:MXSHeroShowView = taped.view as! MXSHeroShowView
        if view.isSelect { return }
        
        view.isSelect = true
        if pickedCount == 0 {
            self.belong?.pickedHero(heroData![view.tag])
            pickedCount += 1
            
            if pickType == .PVP {
                autoHiddenSelfAfter(1500)
            }
            else {
                tipsLabel.text = "请选择客体"
            }
        }
        else if pickedCount == 1 {
            
            self.belong?.pickedHero(heroData![view.tag], isOpponter: true)
            pickedCount += 1
            autoHiddenSelfAfter(1500)
            
            tipsLabel.text = "即将开始。"
        }
        else { return }
    }
        
    func autoHiddenSelfAfter(_ m_second:Int = 1000) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(m_second)) {
//            self.isHidden = true
            self.removeFromSuperview()
        }
    }
    
    
}
