//
//  MonsterListCell.swift
//  Encounter Helper
//
//  Created by Wayne Ohmer on 8/18/19.
//  Copyright © 2019 Tryal by Fyre. All rights reserved.
//

import UIKit

class MonsterListCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    var monster:Monster = Monster()
    var encounter = Encounter()
    var isEncounter = true
    
    @IBOutlet weak var addRemoveButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func updateCell() {
        
        if isEncounter {
            if monster.hitPoints <= 0 {
                let attributeString = NSMutableAttributedString(string: "\(monster.name)")
                attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
                self.nameLabel.attributedText = attributeString
            } else {
                self.nameLabel.attributedText = nil
                nameLabel.text = monster.name
            }
            addRemoveButton.setTitle("-", for: .normal)
        } else {
            let count = encounter.monsters.filter({$0.name == monster.name}).count
            nameLabel.text = count == 0 ? monster.name : "\(monster.name) \(count)"
            addRemoveButton.setTitle("+", for: .normal)
        }
        nameLabel.textColor = monster.damageColor
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            self.layer.borderColor = UIColor.white.cgColor
            self.layer.borderWidth = 2
        } else {
            self.layer.borderWidth = 0
        }
    }
    
}
