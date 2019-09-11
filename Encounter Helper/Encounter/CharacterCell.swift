//
//  CharacterCell.swift
//  Encounter Helper
//
//  Created by Wayne Ohmer on 9/11/19.
//  Copyright © 2019 Tryal by Fyre. All rights reserved.
//

import UIKit

class CharacterCell: UITableViewCell {

    var row:Int?
    var parent:PartyViewController?
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var acField: UITextField!
    @IBOutlet weak var perceptionField: UITextField!
    @IBOutlet weak var levelField: UITextField!
    
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
            Character.shared[thisRow].name = nameField.text ?? ""
            Character.shared[thisRow].level = toInt(levelField)
            Character.shared[thisRow].armorClass = toInt(acField)
            Character.shared[thisRow].passivePerception = toInt(perceptionField)
        } else {
            let character = Character(name: nameField.text ?? "", level: toInt(levelField), armorClass: toInt(acField), passivePerception: toInt(perceptionField))
            Character.shared.append(character)
        }
        parent?.tableView.reloadData()
    }
    
    func toInt(_ textField: UITextField?) -> Int {
        return Int(textField?.text ?? "") ?? 0
        
    }
    
}
