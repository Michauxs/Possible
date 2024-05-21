//
//  MXSRBlockUnitView.swift
//  Possible
//
//  Created by Sunfei on 2024/4/24.
//  Copyright © 2024 boyuan. All rights reserved.
//

import Foundation
import UIKit

class MXSRBlockUnitView: MXSBaseView {
    
    var idx = 0
    var coordinate = (0, 0) {
        didSet {
            idx = coordinate.0*100 + coordinate.1
        }
    }
    
    let selectedView = UIView()
    var selected = false {
        didSet {
            selectedView.isHidden = !selected
        }
    }
    func setSelect(_ select: Bool) {
        if select == self.selected { return }
        self.selected = select
    }
    
    override func setupSubviews() {
        
        self.backgroundColor = .gray
        
        selectedView.frame = self.bounds
        selectedView.backgroundColor = .clear
        selectedView.setRaius(0, borderColor: .white, borderWitdh: 1.0)
        addSubview(selectedView)
        selectedView.isHidden = true
        
    }
    
}
