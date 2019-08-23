//
//  ActionTableViewController.swift
//  Encounter Helper
//
//  Created by Wayne Ohmer on 8/19/19.
//  Copyright © 2019 Tryal by Fyre. All rights reserved.
//

import UIKit

class ActionTableViewController: UITableViewController {

    var monster = Monster()
    var titles = ["Actions","Special Abilities","Legondary Actions"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.estimatedRowHeight = 50
        self.tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return monster.allActions[section].count > 0 ? 45 : 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return monster.allActions[section].count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textAlignment = .center
            headerView.textLabel?.textColor = .white
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.titles[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActionCell", for: indexPath) as! ActionCell

        cell.nameLabel.text = monster.allActions[indexPath.section][indexPath.row].name
        cell.descriptionLabel.text = monster.allActions[indexPath.section][indexPath.row].desc
        
        return cell
    }

    

    
    

}
