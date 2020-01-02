//
//  EncounterDetailController.swift
//  Encounter Helper
//
//  Created by Wayne Ohmer on 9/15/19.
//  Copyright © 2019 Tryal by Fyre. All rights reserved.
//

import UIKit

class EncounterDetailController: UIViewController {

    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var groupLabel: UITextField!
    @IBOutlet weak var descriptionView: UITextView!

    var parentVc: EncounterTableViewController?
    var encounter: Encounter?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameLabel.layer.cornerRadius = 8
        self.groupLabel.layer.cornerRadius = 8
        self.descriptionView.layer.borderColor = UIColor.white.cgColor
        self.descriptionView.layer.borderWidth = 2
        self.descriptionView.layer.cornerRadius = 8
        if let encounter = self.encounter {
            nameLabel.text = encounter.name
            groupLabel.text = encounter.group
            descriptionView.text = encounter.details
        } else {
            groupLabel.text = parentVc?.lastGroup

        }
    }

    @IBAction func saveTouched() {
        self.dismiss(animated: true) {
            if self.encounter != nil {
                self.encounter?.name = self.nameLabel.text ?? ""
                self.encounter?.group = self.groupLabel.text ?? ""
                self.encounter?.details = self.descriptionView.text ?? ""
                self.parentVc?.tableView.reloadData()
             } else {
                let newEncounter = Encounter(name: self.nameLabel.text ?? "")
                newEncounter.details = self.descriptionView.text ?? ""
                newEncounter.group = self.groupLabel.text ?? ""
                Encounter.sharedEncounters[newEncounter.key] = newEncounter
                self.parentVc?.performSegue(withIdentifier: "openEncounter", sender: newEncounter)
            }
        }
    }

}
