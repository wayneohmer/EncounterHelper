//
//  EncounterCell.swift
//  Encounter Helper
//
//  Created by Wayne Ohmer on 8/22/19.
//  Copyright © 2019 Tryal by Fyre. All rights reserved.
//

import UIKit

class EncounterCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var editButton: BlackButton!
    var table: EncounterTableViewController?
    var encounter = Encounter()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func cloudTouched() {
        encounter.saveToCloud()
    }

    @IBAction func dupTouched(_ sender: Any) {
        encounter.duplicate()
        table?.tableView.reloadData()
    }

    @IBAction func editTouched(_ sender: Any) {
        table?.performSegue(withIdentifier: "EditEncounter", sender: encounter)
    }
}
