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
        
        self.layer.cornerRadius = 2.0
        self.layer.borderColor = UIColor.orange.cgColor
        self.layer.borderWidth = 1.0
    }
}

class MXSPickHeroView: MXSBaseView {
    weak var belong:MXSGroundController?
    let hero_width:CGFloat = 80.0
    let hero_height:CGFloat = 120.0
    let between:CGFloat = 3.0
    let numb_col = 4
    let contentView = UIView()
    var conctectViewes:Array<MXSHeroShowView> = Array<MXSHeroShowView>()
    var heroData:Array<MXSHero>? {
        didSet {
            let content_width:CGFloat = hero_width * CGFloat(numb_col) + between * CGFloat(numb_col-1)
            let padding_left:CGFloat = (self.frame.width - content_width) * 0.5
            if (heroData != nil) {
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
            }
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
        view.isSelect = true
        self.belong?.pickedHero(heroData![view.tag])
        
//        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
//            var index = Int.init(arc4random_uniform(UInt32(self.heroData!.count)))
//            if index == view.tag { index += 1 }
//            self.conctectViewes[index].isSelect = true
//
//            self.belong?.autoPickHero(self.heroData![index])
//            self.isHidden = true
//        }
        
    }
    
    
}
