//
//  MXSHeroCmd.swift
//  Possible
//
//  Created by Sunfei on 2020/8/24.
//  Copyright © 2020 boyuan. All rights reserved.
//

import UIKit

class MXSHeroCmd {
    
    var heroData: Array<Dictionary<String,Any>> = []
    
    var allHeroModel :[MXSHero] {
        var all : [MXSHero] = [MXSHero]()
        for attr in MXSHeroCmd.shared.heroData {
            all.append(MXSHero.init(attr))
        }
        return all
    }
    
    lazy var unknownHero: MXSHero = MXSHero.init(["name": "Unknown", "image": "hero_000", "hp": 4, "skill": ["skill_010"], "desc": "unknown" ])
    
    static let shared : MXSHeroCmd = {
        let single = MXSHeroCmd.init()
        let path = Bundle.main.path(forResource: "hero", ofType: "json")
        let url = URL(fileURLWithPath: path!)
        // 带throws的方法需要抛异常
        do {
            let data = try Data(contentsOf: url)
            let array: [[String : Any]] = try! JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [[String : Any]]
            single.heroData = array
        } catch let error as Error? {
            print("读取本地数据出现错误!",error as Any)
        }
        
        return single
    }()
    
    func random() -> MXSHero {
//        let rest = heroData.filter({$0.isFighting == false})
        let index = Int(arc4random_uniform(UInt32(heroData.count)))
        let attr = heroData[index]
        let hero = MXSHero.init(attr)
        return hero
    }
    
    func someoneFromName(_ uu:String) -> MXSHero? {
        if let index = heroData.firstIndex(where: { (hero) -> Bool in hero[kStringImage] as! String == uu }) {
            let attr = heroData[index]
            let hero = MXSHero.init(attr)
            MXSLog(hero, "New a hero")
            return hero
        }
        return nil
    }
    
    func getNewBlankHero() ->MXSHero {
        let hero = MXSHero.init(["name": "Unknown", "image": "hero_000", "hp": 4, "skill": ["skill_010"], "desc": "unknown" ])
        MXSLog(hero, "New blank hero")
        return hero
    }
}
