//
//  SpellCell.swift
//  Encounter Helper
//
//  Created by Wayne Ohmer on 9/22/19.
//  Copyright © 2019 Tryal by Fyre. All rights reserved.
//

import UIKit

class SpellCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            self.layer.borderColor = UIColor.white.cgColor
            self.layer.borderWidth = 2
            self.layer.cornerRadius = 8
        } else {
            self.layer.borderWidth = 0
        }
    }

}
