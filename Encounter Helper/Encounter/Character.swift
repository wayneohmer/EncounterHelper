//
//  Character.swift
//  Encounter Helper
//
//  Created by Wayne Ohmer on 9/10/19.
//  Copyright © 2019 Tryal by Fyre. All rights reserved.
//

import UIKit
import CloudKit

struct StoredParty: Codable {

    var characters = [Character]()
}

struct Character: Codable {

    static var sharedParty = [Character]()

    var name = ""
    var level = Int(0)
    var armorClass = Int(0)
    var passivePerception = Int(10)
    var experiencePoints = Int(0)

    func saveToCloud() {

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        let data = try! encoder.encode(self)
        let container = CKContainer.default()
        let cloudDb = container.publicCloudDatabase
        let cloudEncounter = CKRecord(recordType: "Party", recordID: CKRecord.ID(recordName: name)  )
        cloudEncounter["name"] = name
        cloudEncounter["json"] = String(data: data, encoding: .utf8)!

        cloudDb.save(cloudEncounter) { record, error in
            if error == nil {
                print("\(record?["name"] ?? "No Name")")
            } else {
                cloudDb.delete(withRecordID: CKRecord.ID(recordName: self.name)) { _, error in
                    if error == nil {
                        cloudDb.save(cloudEncounter) { _, error in
                            if error == nil {
                                print("save after delete")
                            } else {
                                print(error.debugDescription)
                            }
                        }
                    } else {
                        print(error.debugDescription)
                    }
                }
            }
        }
    }
}
