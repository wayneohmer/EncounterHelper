//
//  CharacterCell.swift
//  Encounter Helper
//
//  Created by Wayne Ohmer on 9/11/19.
//  Copyright © 2019 Tryal by Fyre. All rights reserved.
//

import UIKit

class CharacterCell: UITableViewCell {

    var row: Int?
    var parent: PartyViewController?

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var acField: UITextField!
    @IBOutlet weak var perceptionField: UITextField!
    @IBOutlet weak var levelField: UITextField!
    @IBOutlet weak var experiencePointField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func saveTouched(_ sender: BlackButton) {

        if let thisRow = row {
            Character.sharedParty[thisRow].name = nameField.text ?? ""
            Character.sharedParty[thisRow].level = toInt(levelField)
            Character.sharedParty[thisRow].armorClass = toInt(acField)
            Character.sharedParty[thisRow].passivePerception = toInt(perceptionField)
            Character.sharedParty[thisRow].experiencePoints = toInt(experiencePointField)
        } else {
            let character = Character(name: nameField.text ?? "", level: toInt(levelField), armorClass: toInt(acField), passivePerception: toInt(perceptionField), experiencePoints: toInt(experiencePointField) )
            Character.sharedParty.append(character)
        }
        parent?.tableView.reloadData()
    }

    func toInt(_ textField: UITextField?) -> Int {
        return Int(textField?.text ?? "") ?? 0

    }

}
