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
    
    var saveable:SavebleEncounter {
        var modelArray = [MonsterModel]()
        for monster in monsters {
            modelArray.append(monster.monsterModel)
        }
        
        return SavebleEncounter(name: name, fileName:fileName, monsters: modelArray)
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
    
    
}

struct SavebleEncounter:Codable {
    
    var name = ""
    var fileName = ""
    var monsters = [MonsterModel]()
}
