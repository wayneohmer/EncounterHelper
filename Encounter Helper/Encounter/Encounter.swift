//
//  Encounter.swift
//  Encounter Helper
//
//  Created by Wayne Ohmer on 8/19/19.
//  Copyright © 2019 Tryal by Fyre. All rights reserved.
//

import UIKit

class Encounter {
    
    static var sharedEncounters = [Encounter]()
    static let savedEncountersPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("encounters")

    static var fileNames = Set<String>()
    
    var name = ""
    var fileName = ""
    var isStarted = false
    var monsters = [Monster]()
    var round = Int(0)
    var partyLevels: [Int] { return party.map( { $0.level } ) }
    var party = [Character]()
    
    var saveable:SavebleEncounter {
        var modelArray = [MonsterModel]()
        for monster in monsters {
            modelArray.append(monster.monsterModel)
        }
        
        return SavebleEncounter(name: name, fileName:fileName, round: round, monsters: modelArray, partyLevels: partyLevels, party: party)
    }
    
    var partyThreshold:(easy:Int, medium:Int,hard:Int, deadly:Int) {
        var returnValue:(easy:Int, medium:Int,hard:Int, deadly:Int) = (0,0,0,0)
        for level in partyLevels {
            returnValue.easy += (Encounter.thresholdDict[level] ?? (0,0,0,0)).easy
            returnValue.medium += (Encounter.thresholdDict[level] ?? (0,0,0,0)).medium
            returnValue.hard += (Encounter.thresholdDict[level] ?? (0,0,0,0)).hard
            returnValue.deadly += (Encounter.thresholdDict[level] ?? (0,0,0,0)).deadly
        }
        return returnValue
    }
    
    var totalXP:Int {
        var xp = self.monsters.map({$0.experience}).reduce(0, +)
        if monsters.count == 2 {
            xp = Int(Double(xp) * 1.5)
        } else if monsters.count > 2 && monsters.count <= 6 {
            xp *= 2
        } else if monsters.count >= 7 && monsters.count <= 10 {
            xp *= Int(Double(xp) * 2.5)
        } else if monsters.count >= 11 && monsters.count <= 14 {
            xp *= 3
        } else if monsters.count >= 15 && monsters.count <= 10 {
            xp *= 4
        }
        
        return xp
    }
    
    var threshold:String {
        if totalXP <= partyThreshold.easy {
            return "Easy"
        } else if totalXP <= partyThreshold.medium {
            return "Medium"
        } else if totalXP <= partyThreshold.hard {
            return "Hard"
        }
        return "Deadly"
    }
    
    convenience init(name:String) {
        self.init()
        self.name = name
    }
    
    convenience init(saveable:SavebleEncounter) {
        self.init()
        self.name = saveable.name
        self.fileName = saveable.fileName
        for mondel in saveable.monsters {
            self.monsters.append(Monster(model: mondel))
        }
    }
    
    func save() {
        
        if self.fileName == "" {
            var fname = self.name
            while Encounter.fileNames.contains(fname) {
                fname = "\(fname)X"
            }
            Encounter.fileNames.insert(fname)
            self.fileName = fname
        }
        do {
            let data = try JSONEncoder().encode(self.saveable)
            do {
                let writePath = Encounter.savedEncountersPath.appendingPathComponent(self.fileName)
                try data.write(to: writePath)
            } catch {
                print(error.localizedDescription)
            }
        } catch {
            print("Save Failed")
        }
    }
    
    static let thresholdDict:[Int:(easy:Int, medium:Int,hard:Int, deadly:Int)] =
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

struct SavebleEncounter:Codable {
    
    var name = ""
    var fileName = ""
    var round = Int(0)
    var monsters = [MonsterModel]()
    var partyLevels = [Int]()
    var party = [Character]()
}
