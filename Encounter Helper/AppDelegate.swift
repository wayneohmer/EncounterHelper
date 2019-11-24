//
//  AppDelegate.swift
//  Encounter Helper
//
//  Created by Wayne Ohmer on 8/18/19.
//  Copyright © 2019 Tryal by Fyre. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?

    let savedMonstersPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("monsters")
    let savedParyPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("party")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        if  !FileManager.default.fileExists(atPath: Encounter.savedEncountersPath.absoluteString) {
            do {
                try FileManager.default.createDirectory(atPath: Encounter.savedEncountersPath.path,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            } catch {
                print("Error creating images folder in documents dir: \(error)")
            }
        }

//        if let monsterData = try? Data(contentsOf: savedMonstersPath) {
//            if let savedMonstsers = try? JSONDecoder().decode(StoredMonsters.self, from: monsterData) {
//                for model in savedMonstsers.monsters {
//                    Monster.sharedMonsters.insert(Monster(model: model))
//                }
//            }
//        }

        if let characterData = try? Data(contentsOf: savedParyPath) {
            if let party = try? JSONDecoder().decode(StoredParty.self, from: characterData) {
                for character in party.characters {
                    Character.sharedParty.append(character)
                }
            }
        }

        self.getAllEncounters()

        if let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: "trialbyfyre.encounter-Helper")?.appendingPathComponent("Documents") {
            if (!FileManager.default.fileExists(atPath: iCloudDocumentsURL.path, isDirectory: nil)) {
                try! FileManager.default.createDirectory(at: iCloudDocumentsURL, withIntermediateDirectories: true, attributes: nil)
            }
        }
        Spell.readSpells()
        Monster.readMonsters()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        saveAllMonsters()
        saveParty()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
     }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
        saveAllMonsters()
        saveParty()
    }

    func getAllEncounters() {
        guard let dir = try? FileManager.default.contentsOfDirectory(atPath: Encounter.savedEncountersPath.path) else { return }
        for path in dir {
            guard let url = URL(string: Encounter.savedEncountersPath.appendingPathComponent(path).absoluteString) else { break }
            do {
                let encounterData = try Data(contentsOf: url)
                if let encounter = try? JSONDecoder().decode(SavebleEncounter.self, from: encounterData) {
                    Encounter.sharedEncounters.append(Encounter(saveable: encounter))
                }
            } catch {
                print(error.localizedDescription)
            }

        }
    }

    func saveAllMonsters() {
        var savedMonstsers = StoredMonsters()
        for monster in Monster.sharedMonsters {
            var model = monster.monsterModel
            model.metaModel = monster.metaMonster
            savedMonstsers.monsters.append(model)
        }
        do {
            let data = try JSONEncoder().encode(savedMonstsers)
            do {
                try data.write(to: self.savedMonstersPath)
            } catch {
                print("Save Monsters Failed")
            }
        } catch {
            print("Save Monsters Failed")
        }
    }

    func saveParty() {
        let storedParty = StoredParty(characters: Character.sharedParty)

        do {
            let data = try JSONEncoder().encode(storedParty)
            do {
                try data.write(to: self.savedParyPath)
            } catch {
                print("Save Party Failed")
            }
        } catch {
            print("Save Party Failed")
        }
    }

}
