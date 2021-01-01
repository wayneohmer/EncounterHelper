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

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
    }

    var model = SpellModel()

    var name: String { return model.name ?? "" }
    var concentration: Bool { return model.concentration ?? "" == "yes" }

    convenience init(model: SpellModel) {
        self.init()
        self.model = model

    }

    static func == (lhs: Spell, rhs: Spell) -> Bool {
        return lhs.name == rhs.name
    }
    
    var saveType:String {
        let regex = try! NSRegularExpression(pattern: "(strength|dexterity|Constitution|intelligence|wisdom|charisma) saving throw")
        let desc = self.model.desc ?? ""
        let range = NSRange(location: 0, length: desc.count)
        let matches = regex.matches(in: desc, range: range)
        if matches.count > 0 {
            let val = matches.map {
                String(desc[Range($0.range, in: desc)!])
                }[0]
            
            let words = val.split(separator: " ").map(String.init)
            if words.count > 0 {
                return String(words[0])
            }
        }
        return ""
    }

    class func readSpells() {
        var spells = [SpellModel]()

        guard let path = Bundle.main.path(forResource: "spells", ofType: "json") else {
            return
        }

        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
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

    var name: String? = ""
    var desc: String? = ""
    var page: String? = ""
    var range: String? = ""
    var components: String? = ""
    var ritual: String? = ""
    var duration: String? = ""
    var concentration: String? = ""
    var castingTime: String? = ""
    var level: String? = ""
    var school: String? = ""
    var classes: String? = ""

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
