//
//  MXSRBlockItem.swift
//  Possible
//
//  Created by Sunfei on 2024/4/9.
//  Copyright © 2024 boyuan. All rights reserved.
//

import UIKit

class MXSRBlockItem: MXSBaseView {
    
    enum MineState : Int {
        case unknown = 0
        case mark = 1
        case check = 2
        case unable = 3
        case show = 4
        case boom = 5
    }
    enum MinePosition : Int {
        case center = 0
        case corner = 1
        case edge = 2
    }
    
    var row : Int = 0
    var col : Int = 0
    var idx : Int = 0
    var state : MineState = .unknown
    
    func setupState(_ sta: MineState) {
        state = sta;
        
        self.backgroundColor = UIColor.init(white: 0.75, alpha: 1.0)
        
        switch state {
        case .unknown:
            titleLabel.text = ""
        case .mark:
            titleLabel.text = "🚩"
        case .check:
            titleLabel.text = ""
        case .unable:
            titleLabel.text = "🤔"
        case .show:
            titleLabel.text = "💣"
        case .boom:
            titleLabel.text = "💥"
        }
    }
    
    var around = 0
    var position : MinePosition = .center {
        didSet {
            switch position {
            case .center:
                around = 8
            case .corner:
                around = 5
            case .edge:
                around = 3
            }
        }
    }
    var clue = 0 {
        didSet {
            titleLabel.text = String(clue)
            titleLabel.textColor = .blue
        }
    }
    
    var isBoom = false
    
    let selectedView = UIView()
    let titleLabel = UILabel.init(text: "", fontSize: 614, textColor: .darkText, align: .center)
    
    var selected = false {
        didSet {
            selectedView.isHidden = !selected
        }
    }
    
    override func layoutSubviews() {
        
        self.backgroundColor = .gray
        
        selectedView.frame = self.bounds
        selectedView.backgroundColor = .clear
        selectedView.setRaius(0, borderColor: .white, borderWitdh: 1.0)
        addSubview(selectedView)
        selectedView.isHidden = true
        
        addSubview(titleLabel)
        titleLabel.frame = self.bounds
//        titleLabel.snp.makeConstraints({ make in
//            make.center.equalTo(self)
//        })
        
        self.setUserInteraction()
    }
    
    override func selfTaped() {
        self.control?.callFunction(byName: "mineViewTaped:", withPara: self)
    }
    
    
    override var info: Any? {
        didSet {
            //
            let dict = info as! [String:Int]
            let row = dict["row"]!
            let col = dict["col"]!
            
            self.row = row
            self.col = col
            self.idx = row * 10 + col
            
//            let name = String(row) + String(col)
//            titleLabel.text = name
        }
    }
    
}
