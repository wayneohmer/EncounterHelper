//
//  MonsterModel.swift
//  Encounter Helper
//
//  Created by Wayne Ohmer on 8/18/19.
//  Copyright © 2019 Tryal by Fyre. All rights reserved.
//

import UIKit

class Monster  {
    
    static var sharedMonsters = [Monster]()
    static var imageFileNames = Set<String>()
    var imagePath:URL { return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(storedImageFileName ?? "")") }


    var monsterModel = MonsterModel()
    var metaMonster = MonsterMetaModel()

    var name:String { return monsterModel.name }
    var size:String { return monsterModel.size }
    var type:String { return monsterModel.type }
    var subtype:String { return monsterModel.subtype }
    var alignment:String { return monsterModel.alignment }
    var armorClass:Int { return monsterModel.armor_class }
    var hitPoints:Int { return monsterModel.hit_points }
    var hitDice:String { return monsterModel.hit_dice }
    var speed:String { return monsterModel.speed }
    var strength:Int { return monsterModel.strength }
    var dexterity:Int { return monsterModel.dexterity }
    var constitution:Int { return monsterModel.constitution }
    var intelligence:Int { return monsterModel.intelligence }
    var wisdom:Int { return monsterModel.wisdom }
    var charisma:Int { return monsterModel.charisma }
    var constitutionSave:Int { return monsterModel.constitution_save ?? 0 }
    var intelligenceSave:Int { return monsterModel.intelligence_save ?? 0 }
    var charismaSave:Int { return monsterModel.charisma_save ?? 0 }
    var dexteritySave:Int { return monsterModel.dexterity_save ?? 0 }
    var strengthSave:Int { return monsterModel.strength_save ?? 0 }
    var wisdomSave:Int { return monsterModel.wisdom_save ?? 0 }
    var perception:Int { return monsterModel.perception ?? 0 }
    var damageVulnerabilities:String { return monsterModel.damage_vulnerabilities }
    var damageResistances:String { return monsterModel.damage_resistances }
    var damageImmunities:String { return monsterModel.damage_immunities }
    var conditionImmunities:String { return monsterModel.condition_immunities }
    var senses:String { return monsterModel.senses }
    var languages:String { return monsterModel.languages }
    var challengeRating:String { return monsterModel.challenge_rating }
    
    var actions:[Action] { return monsterModel.actions ?? [Action]() }
    var specialAbilities:[Action] { return monsterModel.special_abilities ?? [Action]() }
    var legondaryActions:[Action] { return monsterModel.legendary_actions ?? [Action]() }
    
    var allActions:[[Action]] { return [actions,specialAbilities,legondaryActions]}

    var traits:NSAttributedString? {
        guard let htmlData = NSString(string: metaMonster.Traits ?? "").data(using: String.Encoding.unicode.rawValue) else {
            return nil
        }
        let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
        let attributedString = try! NSAttributedString(data: htmlData, options: options, documentAttributes: nil)
        return attributedString
        
    }
    var meta:String? { return metaMonster.meta }
    var actionsDesc:String? { return metaMonster.Actions }
    var imgUrl:String? { return metaMonster.img_url }
    var storedImage:UIImage?
    var storedImageFileName:String? { return monsterModel.storedImageFileName }
    var imageFileName:String? {
        set {
            guard var newName = newValue else { return }
            while Monster.imageFileNames.contains(newName) {
                newName = "\(newName)X"
            }
            Monster.imageFileNames.insert(newName)
            monsterModel.storedImageFileName = newName
        }
        get {
            return storedImageFileName
        }
    }

    var image:UIImage? {
        
        if storedImage != nil {
            return storedImage
        }
        if let imageData = try? Data(contentsOf: imagePath) {
            if let image = UIImage(data: imageData) {
                self.storedImage = image
                return image
            }
        }
        
        guard let url = URL(string:metaMonster.img_url ?? "") else { return nil }
        guard let imageData = try? Data(contentsOf: url) else { return nil }
        self.storedImage = UIImage(data: imageData)
        imageFileName = name
        do {
            try imageData.write(to: imagePath)
        } catch {
            print(imagePath.absoluteString)
        }
        return self.storedImage
    }
    
    convenience init(model:MonsterModel) {
        self.init()
        self.monsterModel = model
        self.metaMonster = model.metaModel ?? MonsterMetaModel()
    }
    
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

struct StoredMonsters: Codable {
    
    var monsters = [MonsterModel]()
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
    var charisma_save:Int? = 0
    var dexterity_save:Int? = 0
    var strength_save:Int? = 0
    
    var wisdom_save:Int? = 0
    var perception:Int? = 0
    var damage_vulnerabilities:String = ""
    var damage_resistances:String = ""
    var damage_immunities:String = ""
    var condition_immunities:String = ""
    var senses:String = ""
    var languages:String = ""
    var challenge_rating:String = ""
    var storedImageFileName:String? = ""
    
    var special_abilities:[Action]?
    var actions:[Action]?
    var legendary_actions:[Action]?
    var metaModel:MonsterMetaModel?


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
