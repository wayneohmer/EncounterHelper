//
//  Encounter.swift
//  Encounter Helper
//
//  Created by Wayne Ohmer on 8/19/19.
//  Copyright © 2019 Tryal by Fyre. All rights reserved.
//

import UIKit
import CloudKit

class Encounter {

    static var sharedEncounters = [String: Encounter]()
    static let savedEncountersPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("encounters")

    static var fileNames = Set<String>()

    var name = ""
    var group = ""
    var details = ""
    var isStarted = false
    var monsters = [Monster]()
    var round = Int(0)
    var partyLevels: [Int] { return Character.sharedParty.map({ $0.level }) }
    var isCompleted = false
    var key: String { return "\(group)|\(name)"}

    var saveable: SavebleEncounter {
        return SavebleEncounter(name: name, group: group, details: details, round: round, monsters: monsters.map({$0.monsterModel}), isCompleted: isCompleted)
    }

    var cloud: CloudEncounter {
        return CloudEncounter(name: name, group: group, details: details, round: round, monsters: monsters.map({ $0.name }), isCompleted: isCompleted)
    }

    var partyThreshold:(easy: Int, medium: Int, hard: Int, deadly: Int) {
        var returnValue:(easy: Int, medium: Int, hard: Int, deadly: Int) = (0, 0, 0, 0)
        for level in partyLevels {
            returnValue.easy += (Encounter.thresholdDict[level] ?? (0, 0, 0, 0)).easy
            returnValue.medium += (Encounter.thresholdDict[level] ?? (0, 0, 0, 0)).medium
            returnValue.hard += (Encounter.thresholdDict[level] ?? (0, 0, 0, 0)).hard
            returnValue.deadly += (Encounter.thresholdDict[level] ?? (0, 0, 0, 0)).deadly
        }
        return returnValue
    }

    var totalXP: Int {
        var xp = self.monsters.map({$0.experience}).reduce(0, +)
        if monsters.count == 2 {
            xp = Int(Double(xp) * 1.5)
        } else if monsters.count > 2 && monsters.count <= 6 {
            xp *= 2
        } else if monsters.count >= 7 && monsters.count <= 10 {
            xp = Int(Double(xp) * 2.5)
        } else if monsters.count >= 11 && monsters.count <= 14 {
            xp *= 3
        } else if monsters.count >= 15 && monsters.count <= 10 {
            xp *= 4
        }

        return xp
    }

    var threshold: String {
        if totalXP <= partyThreshold.easy {
            return "Easy"
        } else if totalXP <= partyThreshold.medium {
            return "Medium"
        } else if totalXP <= partyThreshold.hard {
            return "Hard"
        }
        return "Deadly"
    }

    convenience init(name: String) {
        self.init()
        self.name = name
    }

    convenience init(saveable: SavebleEncounter) {
        self.init()
        self.name = saveable.name
        self.group = saveable.group
        self.details = saveable.details
        for mondel in saveable.monsters {
            self.monsters.append(Monster(model: mondel))
        }
    }

    convenience init(cloud: CloudEncounter) {
        self.init()
        self.name = cloud.name
        self.group = cloud.group
        self.details = cloud.details
        for name in cloud.monsters {
            Monster.fetchFromCloudWith(name: "\(self.name)|\(name)") { monster in
                self.monsters.append(monster)
            }
        }
    }

    func remove() {
        let path = Encounter.savedEncountersPath.appendingPathComponent(self.key)
        try? FileManager.default.removeItem(at: path)
        Encounter.sharedEncounters.removeValue(forKey: self.key)

    }

    func save() {

        do {
            let data = try JSONEncoder().encode(self.saveable)
            do {
                let writePath = Encounter.savedEncountersPath.appendingPathComponent(self.key)
                try data.write(to: writePath)
            } catch {
                print(error.localizedDescription)
            }
        } catch {
            print("Save Failed")
        }
        Encounter.sharedEncounters[self.key] = self
    }

    func saveToCloud() {

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        let data = try! encoder.encode(cloud)
        let container = CKContainer.default()
        let cloudDb = container.publicCloudDatabase
        let cloudEncounter = CKRecord(recordType: "Encounter", recordID: CKRecord.ID(recordName: name)  )
        cloudEncounter["name"] = name
        cloudEncounter["json"] = String(data: data, encoding: .utf8)!
        cloudDb.save(cloudEncounter) { record, error in
            if error == nil {
                print("\(record?["name"] ?? "No Name")")
            } else {
                print(error.debugDescription)
            }
        }
        for monster in monsters {
            monster.saveToCloudWith(name: "\(name)|\(monster.name)")
        }

    }

    func duplicate() {
        let encounter = Encounter(saveable: self.saveable)
        var components = encounter.name.split(separator: " ")

        if var num = Int(String(components.last ?? "")) {
            num += 1
            components.removeLast()
            encounter.name = "\(components.joined(separator: " ")) \(num)"
            while Encounter.sharedEncounters.filter({ $0.key == encounter.key }).count > 0 {
                num += 1
                encounter.name = "\(components.joined(separator: " ")) \(num)"
            }
        } else {
            self.remove()
            self.name = "\(encounter.name) 1"
            encounter.name = "\(encounter.name) 2"
        }
        self.save()
        encounter.save()
    }

    static let thresholdDict: [Int:(easy: Int, medium: Int, hard: Int, deadly: Int)] =
        [1: (25, 50, 75, 100),
         2: (50, 100, 150, 200),
         3: (75, 150, 225, 400),
         4: (125, 250, 375, 500),
         5: (250, 500, 750, 1100),
         6: (300, 600, 900, 1400),
         7: (350, 750, 1100, 1700),
         8: (450, 900, 1400, 2100),
         9: (550, 1100, 1600, 2400),
         10: (600, 1200, 1900, 2800),
         11: (800, 1600, 2400, 3600),
         12: (1000, 2000, 3000, 4500),
         13: (1100, 2200, 3400, 5100),
         14: (1250, 2500, 3800, 5700),
         15: (1400, 2800, 4300, 6400),
         16: (1600, 3200, 4800, 7200),
         17: (2000, 3900, 5900, 8800),
         18: (2100, 4200, 6300, 9500),
         19: (2400, 4900, 7300, 10900),
         20: (2800, 5700, 8500, 12700)]

}

struct SavebleEncounter: Codable {

    var name = ""
    var group = ""
    var details = ""
    var round = Int(0)
    var monsters = [MonsterModel]()
    var isCompleted = false

}

struct CloudEncounter: Codable {

    var name = ""
    var group = ""
    var details = ""
    var round = Int(0)
    var monsters = [String]()
    var isCompleted = false

}
