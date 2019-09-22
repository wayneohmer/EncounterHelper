//
//  SpellMasterController.swift
//  Encounter Helper
//
//  Created by Wayne Ohmer on 9/22/19.
//  Copyright © 2019 Tryal by Fyre. All rights reserved.
//

import UIKit

class SpellMasterController: UITableViewController {

    var spells = [SpellModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UITableView()

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spells.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SpellCell", for: indexPath) as! SpellCell

        cell.nameLabel.text = spells[indexPath.row].name

        return cell
    }

    @IBAction func doneTouched(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let controller = segue.destination as! SpellDetailController
            controller.spell = self.spells[indexPath.row]
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }

}
