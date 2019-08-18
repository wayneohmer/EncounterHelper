//
//  MonsterModel.swift
//  Encounter Helper
//
//  Created by Wayne Ohmer on 8/18/19.
//  Copyright © 2019 Tryal by Fyre. All rights reserved.
//

import UIKit

class Monster {
    
    static var sharedMonsters = [Monster]()

    var monsterModel = MonsterModel()
    var metaMonster = MonsterMetaModel()
    
    class func readMonsters() {
        var monsters = [MonsterModel]()
        var metaMonsters = [MonsterMetaModel]()

        guard let path = Bundle.main.path(forResource: "5e-SRD-Monsters", ofType: "json") else {
            return
        }
        guard let metapath = Bundle.main.path(forResource: "srd_5e_monsters", ofType: "json") else {
            return
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath:path), options: .mappedIfSafe)
            do {
                let decoder = JSONDecoder()
                monsters = try decoder.decode([MonsterModel].self, from: data)
            } catch {
            }
        } catch {
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath:metapath), options: .mappedIfSafe)
            do {
                let decoder = JSONDecoder()
                metaMonsters = try decoder.decode([MonsterMetaModel].self, from: data)
            } catch {
            }
        } catch {
        }
        
        for monsterModel in monsters {
            let monster = Monster()
            monster.monsterModel = monsterModel
            for metaMonster in metaMonsters {
                if metaMonster.name == monsterModel.name {
                    monster.metaMonster = metaMonster
                    break;
                }
            }
            Monster.sharedMonsters.append(monster)
        }
    }
    
}

struct MonsterModel: Codable  {
    
    var name:String = ""
    var size:String = ""
    var type:String = ""
    var subtype:String = ""
    var alignment:String = ""
    var armor_class = 0
    var hit_points = 0
    var hit_dice:String = ""
    var speed:String = ""
    var strength = 0
    var dexterity = 0
    var constitution = 0
    var intelligence = 0
    var wisdom = 0
    var charisma = 0
    var constitution_save:Int? = 0
    var intelligence_save:Int? = 0
    var wisdom_save:Int? = 0
    var history:Int? = 0
    var perception:Int? = 0
    var damage_vulnerabilities:String = ""
    var damage_resistances:String = ""
    var damage_immunities:String = ""
    var condition_immunities:String = ""
    var senses:String = ""
    var languages:String = ""
    var challenge_rating:String = ""
    
    var special_abilities:[Action]?
    var actions:[Action]?
    var legendary_actions:[Action]?

}

struct Action: Codable {
    var name:String = ""
    var desc:String = ""
    var attack_bonus:Int?
    var damage_dice:String?
    var damage_bonus:Int?
}

struct MonsterMetaModel: Codable  {
    
    var name:String? = ""
    var Traits:String? = ""
    var meta:String? = ""
    var Actions:String? = ""
    var img_url:String? = ""

}
