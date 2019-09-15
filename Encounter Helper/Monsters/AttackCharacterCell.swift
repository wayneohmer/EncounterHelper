//
//  AttackCharacterCell.swift
//  Encounter Helper
//
//  Created by Wayne Ohmer on 9/14/19.
//  Copyright © 2019 Tryal by Fyre. All rights reserved.
//

import UIKit

class AttackCharacterCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            self.contentView.layer.borderColor = UIColor.white.cgColor
            self.contentView.layer.cornerRadius = 10
            self.contentView.layer.borderWidth = 2
        } else {
            self.contentView.layer.borderWidth = 0
        }
    }

}
