//
//  MonsterModel.swift
//  Encounter Helper
//
//  Created by Wayne Ohmer on 8/18/19.
//  Copyright © 2019 Tryal by Fyre. All rights reserved.
//

import UIKit
import CloudKit

enum Attribute: String {

    case Strength
    case Dexterity
    case Constitution
    case Intelligence
    case Wisdom
    case Charisma

}

class Monster: Hashable {

    static let crDict: [String: Int] = ["1/8": 25,
                                      "1/4": 50,
                                      "1/2": 100,
                                      "1": 200,
                                      "2": 450,
                                      "3": 700,
                                      "4": 1100,
                                      "5": 1800,
                                      "6": 2300,
                                      "7": 2900,
                                      "8": 3900,
                                      "9": 5000,
                                      "10": 5900,
                                      "11": 7200,
                                      "12": 8400,
                                      "13": 10000,
                                      "14": 11500,
                                      "15": 13000,
                                      "16": 15000,
                                      "17": 18000,
                                      "18": 20000,
                                      "19": 22000,
                                      "20": 25000,
                                      "21": 33000,
                                      "22": 41000,
                                      "23": 50000,
                                      "24": 62000,
                                      "25": 75000,
                                      "30": 75000]

    static var sharedMonsters = Set<Monster>()

    static var imageFileNames = Set<String>()
    var imagePath: URL { return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("images\(storedImageFileName ?? "")") }

    var monsterModel = MonsterModel()
    var metaMonster: MonsterMetaModel {
        set {
            self.monsterModel.metaModel = newValue
        }
        get {
            return monsterModel.metaModel ?? MonsterMetaModel()
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
    }
    var name: String { return monsterModel.name }
    var size: String { return monsterModel.size }
    var type: String { return monsterModel.type }
    var subtype: String { return monsterModel.subtype ?? "" }
    var alignment: String { return monsterModel.alignment }
    var armorClass: Int { return monsterModel.armor_class ?? 0 }
    var hitPoints: Int { return monsterModel.currentHitPoints ?? monsterModel.maxHitPoints ?? monsterModel.hit_points }
    var damageColor: UIColor {
        guard let hp = monsterModel.currentHitPoints, let maxHp = monsterModel.maxHitPoints else { return .white }
        let GB = CGFloat(hp) / CGFloat(maxHp)
        return UIColor(red: 1, green: GB, blue: GB, alpha: 1)
    }
    var hitDice: String { return monsterModel.hit_dice }
    var speed: String { return monsterModel.speed }
    var strength: Int { return monsterModel.strength }
    var dexterity: Int { return monsterModel.dexterity }
    var constitution: Int { return monsterModel.constitution }
    var intelligence: Int { return monsterModel.intelligence }
    var wisdom: Int { return monsterModel.wisdom }
    var charisma: Int { return monsterModel.charisma }
    var constitutionSave: Int? { return monsterModel.constitution_save}
    var intelligenceSave: Int? { return monsterModel.intelligence_save }
    var charismaSave: Int? { return monsterModel.charisma_save }
    var dexteritySave: Int? { return monsterModel.dexterity_save }
    var strengthSave: Int? { return monsterModel.strength_save }
    var wisdomSave: Int? { return monsterModel.wisdom_save  }
    var perception: Int { return monsterModel.perception ?? 0}
    var damageVulnerabilities: String { return monsterModel.damage_vulnerabilities ?? monsterModel.vulnerable ?? "" }
    var damageResistances: String { return monsterModel.damage_resistances ?? "" }
    var damageImmunities: String { return monsterModel.damage_immunities ?? "" }
    var conditionImmunities: String { return monsterModel.condition_immunities ?? ""}
    var senses: String { return monsterModel.senses }
    var languages: String { return monsterModel.languages ?? "" }
    var challengeRating: Float {
        if let cr = Float(monsterModel.challenge_rating) {
            return cr

        } else {
            let components = monsterModel.challenge_rating.split(separator: "/")
            if let num = Float(components[0]), let den = Float(components[1]), den != 0 {
                return num/den
            }
        }

        return 0

    }
    var conditions: String {
        var returnString = Array(monsterModel.conditions ?? Set<String>()).sorted().joined(separator: ", ")
        if let eotDmg = monsterModel.eotDamage {
            returnString += " EOT: \(eotDmg) Damage"
            if let eotSave = monsterModel.eotSave {
                returnString += " \(eotSave) Save DC:\(eotSaveDC ?? 0)"
            }
        } else {
            if let eotSave = monsterModel.eotSave {
                returnString += " EOT: \(eotSave) Save DC:\(eotSaveDC ?? 0)"
            }
        }

        return returnString

    }
    var eotSave: String? { return monsterModel.eotSave }
    var eotSaveDC: Int? { return monsterModel.eotSaveDC }
    var eotDamage: Int? { return monsterModel.eotDamage }
    var experience: Int { return Monster.crDict[monsterModel.challenge_rating] ?? 0 }

    var actions: [Action] { return monsterModel.actions ?? [Action]() }
    var specialAbilities: [Action] { return monsterModel.special_abilities ?? [Action]() }
    var legondaryActions: [Action] { return monsterModel.legendary_actions ?? [Action]() }
    var reactions: [Action] { return monsterModel.reactions ?? [Action]() }
    var log: [Action] { return monsterModel.log ?? [Action]() }

    var allActions: [[Action]] { return [actions, specialAbilities, legondaryActions, reactions, log]}

    var traits: NSAttributedString? {
        guard let htmlData = NSString(string: metaMonster.Traits ?? "").data(using: String.Encoding.unicode.rawValue) else {
            return nil
        }
        let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
        let attributedString = try! NSAttributedString(data: htmlData, options: options, documentAttributes: nil)
        return attributedString

    }
    var meta: String? { return metaMonster.meta ?? "\(size) \(type), \(alignment)"  }
    var actionsDesc: String? { return metaMonster.Actions }
    var imgUrl: String? { return metaMonster.img_url }
    var storedImage: UIImage?
    var storedImageFileName: String? { return monsterModel.storedImageFileName }
    var imageFileName: String? {
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

    static var condtionsDesc: [String: [String]] = {

        guard let path = Bundle.main.path(forResource: "conditions", ofType: "json") else {
            return [String: [String]]()
        }
        let fileURL = URL(fileURLWithPath: path)
        let data = try! Data(contentsOf: fileURL, options: .mappedIfSafe)
        let decoder = JSONDecoder()
        let conditions = try! decoder.decode(Conditions.self, from: data)
        return conditions.contentDict ?? [String: [String]]()
    }()

    var image: UIImage? {
        set {
            if let newValue = newValue {
                storedImage = newValue
                imageFileName = name
                self.monsterModel.imageData =  newValue.jpegData(compressionQuality: 0)
            }
        }
        get {
            if storedImage != nil {
                return storedImage
            }

            if let image = UIImage(data: self.monsterModel.imageData ?? Data()) {
                self.storedImage = image
                return image
            }

            if let image = UIImage(named: self.name) {
                self.storedImage = image
                imageFileName = name
                self.monsterModel.imageData = self.storedImage?.jpegData(compressionQuality: 0)
                return image
            }

            if let imageData = try? Data(contentsOf: imagePath) {
                if let image = UIImage(data: imageData) {
                    self.storedImage = image
                    self.monsterModel.imageData = imageData
                    return image
                }
            }

            guard let url = URL(string: metaMonster.img_url ?? "") else { return nil }
            guard let imageData = try? Data(contentsOf: url) else { return nil }
            self.monsterModel.imageData = imageData
            self.storedImage = UIImage(data: imageData)
            imageFileName = name
            return self.storedImage
        }
    }

    convenience init(model: MonsterModel) {
        self.init()
        self.monsterModel = model
        if let imageData = model.imageData {
            self.storedImage = UIImage(data: imageData)
        }
        self.metaMonster = model.metaModel ?? MonsterMetaModel()
        if self.monsterModel.currentHitPoints == nil {
            if self.monsterModel.maxHitPoints == nil {
                self.monsterModel.maxHitPoints = self.monsterModel.hit_points
            }
            self.monsterModel.currentHitPoints = self.monsterModel.maxHitPoints
        }
    }

    func addLog(desc: String) {
        if monsterModel.log == nil {
            monsterModel.log = [Action]()
        }
        monsterModel.log?.insert(Action(desc: desc), at: 0)
    }

    func restoreWith(model: MonsterModel) {
        self.monsterModel = model
    }

    func randomizeHP() {
        let plusString = monsterModel.hit_dice.split(separator: "+")
        let components = plusString[0].split(separator: "d")
        let dice = FyreDice()
        if let mult = Int(components[0]), let d = Int(components[1]) {
            dice.add(multipier: mult, d: d)
            dice.modifier = mult * ((monsterModel.constitution - 10) / 2)
            dice.roll()
            monsterModel.maxHitPoints = dice.rollValue
            monsterModel.currentHitPoints = monsterModel.maxHitPoints
        }
    }

    class func readMonsters() {
        var monsters = [MonsterModel]()
        var metaMonsters = [MonsterMetaModel]()

        guard var path = Bundle.main.path(forResource: "5e-SRD-Monsters", ofType: "json") else {
            return
        }
        guard let metapath = Bundle.main.path(forResource: "srd_5e_monsters", ofType: "json") else {
            return
        }

        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            do {
                let decoder = JSONDecoder()
                monsters = try decoder.decode([MonsterModel].self, from: data)
            } catch {
            }
        } catch {
        }

        path = Bundle.main.path(forResource: "tomeOfBeasts", ofType: "json")!

        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            do {
                let decoder = JSONDecoder()
                let extraMonsters = try decoder.decode([MonsterModel].self, from: data)
                monsters.append(contentsOf: extraMonsters)
            } catch {
                print(error)
            }
        } catch {
        }
        
        path = Bundle.main.path(forResource: "ExtraMonsters", ofType: "json")!

        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            do {
                let decoder = JSONDecoder()
                let extraMonsters = try decoder.decode([MonsterModel].self, from: data)
                monsters.append(contentsOf: extraMonsters)
            } catch {
                print(error)
            }
        } catch {
        }

        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: metapath), options: .mappedIfSafe)
            do {
                let decoder = JSONDecoder()
                metaMonsters = try decoder.decode([MonsterMetaModel].self, from: data)
            } catch {
            }
        } catch {
        }

        path = Bundle.main.path(forResource: "tomeOfBeasts", ofType: "json")!

        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            do {
                let decoder = JSONDecoder()
                let extraMonsters = try decoder.decode([MonsterModel].self, from: data)
                monsters.append(contentsOf: extraMonsters)
            } catch {
                print(error)
            }
        } catch {
        }

        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: metapath), options: .mappedIfSafe)
            do {
                let decoder = JSONDecoder()
                metaMonsters = try decoder.decode([MonsterMetaModel].self, from: data)
            } catch {
            }
        } catch {
        }

        for var monsterModel in monsters {
            for (idx, action) in monsterModel.special_abilities?.enumerated() ?? [Action]().enumerated() {
                if let spellNames = action.spellNames {
                    monsterModel.special_abilities?[idx].spells = [SpellModel]()
                    for name in spellNames {
                        if let spell = Spell.sharedSpells.first(where: { $0.name.lowercased() == name }) {
                            monsterModel.special_abilities?[idx].spells?.append(spell.model)
                        }
                    }
                }
            }
            let monster = Monster(model: monsterModel)
            for metaMonster in metaMonsters {
                if metaMonster.name == monsterModel.name {
                    monster.metaMonster = metaMonster
                    break
                }
            }
            Monster.sharedMonsters.insert(monster)
        }
    }

    func saveToCloudWith(name: String) {

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        let data = try! encoder.encode(monsterModel)
        let container = CKContainer.default()
        let cloudDb = container.publicCloudDatabase
        let cloudMonster = CKRecord(recordType: "Monster", recordID: CKRecord.ID(recordName: name))

        cloudMonster["recordName"] = name
        cloudMonster["name"] = name
        cloudMonster["json"] = String(data: data, encoding: .utf8)!
        cloudDb.save(cloudMonster) { record, error in
            if error == nil {
                print("\(record?["name"] ?? "No Name")")
            } else {
                print(error.debugDescription)
            }
        }

    }
    class func fetchFromCloudWith(name: String, competion: @escaping (Monster) -> Void) {

        let cloudDb = CKContainer.default().publicCloudDatabase
        cloudDb.fetch(withRecordID: CKRecord.ID(recordName: name)) { record, _ in
            if let record = record {
                if let json = record["json"] as? String {
                    let decoder = JSONDecoder()
                    if let monsterModel = try? decoder.decode(MonsterModel.self, from: json.data(using: .utf8, allowLossyConversion: true) ?? Data()) {
                        let monster = Monster(model: monsterModel)
                        competion(monster)
                    }
                }
            }
        }
    }

    static func == (lhs: Monster, rhs: Monster) -> Bool {
        return lhs.name == rhs.name
    }

}

struct StoredMonsters: Codable {

    var monsters = [MonsterModel]()
}

struct MonsterModel: Codable {

    var name: String = ""
    var size: String = ""
    var type: String = ""
    var subtype: String? = ""
    var alignment: String = ""
    var armor_class: Int? = 0
    var hit_points = 0
    var hit_dice: String = ""
    var speed: String = ""
    var strength = 0
    var dexterity = 0
    var constitution = 0
    var intelligence = 0
    var wisdom = 0
    var charisma = 0
    var constitution_save: Int? = 0
    var intelligence_save: Int? = 0
    var charisma_save: Int? = 0
    var dexterity_save: Int? = 0
    var strength_save: Int? = 0

    var wisdom_save: Int? = 0
    var perception: Int? = 0
    var damage_vulnerabilities: String? = ""
    var vulnerable: String? = ""
    var damage_resistances: String? = ""
    var damage_immunities: String? = ""
    var condition_immunities: String? = ""
    var senses: String = ""
    var languages: String? = ""
    var challenge_rating: String = ""
    var storedImageFileName: String? = ""
    var currentHitPoints: Int?
    var maxHitPoints: Int?
    var conditions: Set<String>? = Set<String>()
    var eotDamage: Int?
    var eotSave: String?
    var eotSaveDC: Int?
    var imageData: Data?

    var special_abilities: [Action]?
    var actions: [Action]?
    var legendary_actions: [Action]?
    var reactions: [Action]?
    var log: [Action]?
    var metaModel: MonsterMetaModel?

}

struct Action: Codable {
    var name: String = ""
    var desc: String = ""
    var attack_bonus: Int?
    var damage_dice: String?
    var damage_bonus: Int?
    var spellNames: [String]?
    var spells: [SpellModel]?

    init(desc: String) {
        self.desc = desc
    }
}

struct MonsterMetaModel: Codable {

    var name: String?
    var Traits: String?
    var meta: String?
    var Actions: String?
    var img_url: String?

}

struct Conditions: Codable {
    var contentDict: [String: [String]]?
}
