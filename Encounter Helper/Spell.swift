//
//  Spell.swift
//  Encounter Helper
//
//  Created by Wayne Ohmer on 9/7/19.
//  Copyright © 2019 Tryal by Fyre. All rights reserved.
//

import UIKit

class Spell: Hashable {
    
    static var sharedSpells = Set<Spell>()
    
    var hashValue:Int { return self.name.hashValue }

    var spellModel = SpellModel()
    
    var name:String { return spellModel.name ?? "" }
    
    convenience init(model:SpellModel) {
        self.init()
        self.spellModel = model
        
    }
    
    static func == (lhs: Spell, rhs: Spell) -> Bool {
        return lhs.name == rhs.name
    }
    
    class func readSpells() {
        var spells = [SpellModel]()
        
        guard let path = Bundle.main.path(forResource: "spells", ofType: "json") else {
            return
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath:path), options: .mappedIfSafe)
            do {
                let decoder = JSONDecoder()
                spells = try decoder.decode([SpellModel].self, from: data)
            } catch {
                print(error)
            }
        } catch {
        }
        for spellModel in spells {
            Spell.sharedSpells.insert(Spell(model: spellModel))
        }
    }
}

struct SpellModel: Codable {
    
    var name:String? = ""
    var desc:String? = ""
    var page:String? = ""
    var range:String? = ""
    var components:String? = ""
    var ritual:String? = ""
    var duration:String? = ""
    var concentration:String? = ""
    var castingTime:String? = ""
    var level:String? = ""
    var school:String? = ""
    var classes:String? = ""

    enum CodingKeys: String, CodingKey {
        
        case classes = "class"
        case castingTime = "casting_time"
        
        case name
        case desc
        case page
        case range
        case components
        case ritual
        case duration
        case concentration
        case level
        case school
    }
    
}
