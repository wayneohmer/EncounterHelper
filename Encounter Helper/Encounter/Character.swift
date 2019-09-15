//
//  Character.swift
//  Encounter Helper
//
//  Created by Wayne Ohmer on 9/10/19.
//  Copyright © 2019 Tryal by Fyre. All rights reserved.
//

import UIKit

struct StoredParty: Codable {

    var characters = [Character]()
}

struct Character: Codable {

    static var sharedParty = [Character]()

    var name = ""
    var level = Int(0)
    var armorClass = Int(0)
    var passivePerception = Int(10)

}
