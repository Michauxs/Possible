//
//  MXSPokerView.swift
//  Possible
//
//  Created by Sunfei on 2020/8/19.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit

class MXSPokerView: MXSBaseView {
    weak var belong: MXSPoker?
    let actionTextTranslater: [PokerAction:String] = [.attack:"攻",
                                                      .defense:"守",
                                                      .steal:"偷窃",
                                                      .destroy:"破坏",
                                                      .warFire:"战火",
                                                      .arrowes:"箭雨",
                                                      .duel:"暗器",
                                                      .remedy:"恢复",
                                                      .detect:"侦察"]
    
    var contentView: UIView = UIView()
    var colorSign: UIImageView = UIImageView()
    var numberLabel: UILabel = UILabel.init(text: "0", fontSize: 614, textColor: .black, align: .center)
    var actionLabel: UILabel = UILabel.init(text: "0", fontSize: 618, textColor: .black, align: .center)
    var actionGuiseLabel: UILabel = UILabel.init(text: "0", fontSize: 313, textColor: .black, align: .center)
    
    var isUp: Bool = false {
        didSet {
            let org_y = self.frame.origin.y
            var offset_y:CGFloat = 0.0
            if isUp {
                if org_y == 0.0 { return }
                offset_y = 0.0
            } else {
                if org_y == 5.0 { return }
                offset_y = 5.0
                belong?.actionGuise = belong!.actionFate
                belong?.colorGuise = belong!.color
            }
            
            self.isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.1, animations: {
                self.frame = CGRect.init(x: self.frame.origin.x, y: offset_y, width: MXSSize.Pw, height: MXSSize.Ph)
            }) { (success) in
                self.isUserInteractionEnabled = true
            }
        }
    }
    var showWidth: CGFloat = MXSSize.Pw {
        didSet {
            var font_size = showWidth*0.5
            if font_size > 20 { font_size = 20 }
            else if font_size < 13 { font_size = 13 }
            //actionLabel.font = UIFont.systemFont(ofSize: font_size, weight: .bold)
            actionLabel.font = UIFont.init(name: FontXingKai, size: font_size)
            contentView.snp.updateConstraints({ (m) in
                m.width.equalTo(showWidth)
            })
        }
    }
    
    
    weak var controller: MXSViewController? {
        didSet {
            self.isUserInteractionEnabled = true
            self.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(didTapedSelf)))
        }
    }
    @objc func didTapedSelf() {
        MXSLog("poker did taped")
        self.controller?.perform(#selector(MXSGroundController.someonePokerTaped(_:)), with: self)
//        self.controller?.perform(#selector(someonePokerTapedWithPokerView:), with: self)
//        let _ = self.controller?.perform(Selector(("someonePokerTaped:")), with: self)?.takeUnretainedValue()
//        self.controller?.someonePokerTaped(self)
    }
    
    var numb: Int? {
        didSet {
            var numb_string:String = String.init(format: "%d", numb!)
            if numb == 1 { numb_string = "A" }
            else if numb == 11 { numb_string = "J" }
            else if numb == 12 { numb_string = "Q" }
            else if numb == 13 { numb_string = "K" }
            numberLabel.text = numb_string
        }
    }
    var color: PokerColor? {
        didSet {
            switch color {
            case .heart:
                colorSign.image = UIImage.init(named: "heart")
                numberLabel.textColor = .red
                actionLabel.textColor = .red
            case .club:
                colorSign.image = UIImage.init(named: "club")
                numberLabel.textColor = .black
                actionLabel.textColor = .black
            case .spade:
                colorSign.image = UIImage.init(named: "spade")
                numberLabel.textColor = .black
                actionLabel.textColor = .black
            case .diamond:
                colorSign.image = UIImage.init(named: "diamond")
                numberLabel.textColor = .red
                actionLabel.textColor = .red
            default:
                break
            }
        }
    }
    var action: PokerAction? {
        didSet{
            actionLabel.text = actionTextTranslater[action!]
            actionGuiseLabel.text = actionTextTranslater[action!]
        }
    }
    var actionGuise: PokerAction? {
        didSet{
            actionGuiseLabel.text = actionTextTranslater[actionGuise!]
        }
    }
    
    override func setupSubviews() {
        bounds = CGRect.init(x: 0, y: 0, width: MXSSize.Pw, height: MXSSize.Ph)
//        NSLog("w:%.2f  h:%.2f", MXSSize.PokerWidth, MXSSize.PokerHeight)
        backgroundColor = .white
        layer.cornerRadius = 3.0
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 1.0
        clipsToBounds = true
        
        addSubview(contentView)
        contentView.snp.makeConstraints { (m) in
            m.top.equalTo(self)
            m.left.equalTo(self)
            m.bottom.equalTo(self)
            m.width.equalTo(MXSSize.Pw)
        }
        
        contentView.addSubview(numberLabel)
        numberLabel.snp.makeConstraints({ (m) in
            m.left.equalTo(contentView).offset(5)
            m.top.equalTo(contentView).offset(2)
        })
        
        let sign_width = 10.0
        colorSign = UIImageView.init(image: UIImage.init(named: "head_default"))
        contentView.addSubview(colorSign)
        colorSign.snp.makeConstraints({ (m) in
            m.centerX.equalTo(numberLabel)
            m.top.equalTo(numberLabel.snp_bottom)
            m.size.equalTo(CGSize.init(width: sign_width, height: sign_width))
        })
        
        actionLabel.numberOfLines = 0
        contentView.addSubview(actionLabel)
        actionLabel.snp.makeConstraints({ (m) in
            m.top.equalTo(colorSign.snp_bottom).offset(5)
            m.centerX.equalTo(contentView)
            m.width.equalTo(contentView)
        })
        
        actionGuiseLabel.backgroundColor = .alphaBlack
        contentView.addSubview(actionGuiseLabel)
        actionGuiseLabel.snp.makeConstraints({ (m) in
            m.width.equalTo(contentView)
            m.bottom.equalTo(contentView)
            m.centerX.equalTo(contentView)
            m.height.equalTo(20)
        })
        actionGuiseLabel.isHidden = true
    }
    

}
