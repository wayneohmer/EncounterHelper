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
    let savedEncountersPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("encounters")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if let monsterData = try? Data(contentsOf: savedMonstersPath) {
            if let savedMonstsers = try? JSONDecoder().decode(StoredMonsters.self, from: monsterData) {
                for model in savedMonstsers.monsters {
                    Monster.sharedMonsters.append(Monster(model:model))
                }
            }
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        saveAllMonsters()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
     }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
        saveAllMonsters()
    }

    func saveAllMonsters(){
        var savedMonstsers = StoredMonsters()
        for monster in Monster.sharedMonsters {
            var model = monster.monsterModel
            model.metaModel = monster.metaMonster
            savedMonstsers.monsters.append(model)
        }
        do {
            let data = try JSONEncoder().encode(savedMonstsers)
            do {
                try data.write(to: savedMonstersPath)
            } catch {
                print("Save Failed")
            }
        } catch {
            print("Save Failed")
        }
    }

}

