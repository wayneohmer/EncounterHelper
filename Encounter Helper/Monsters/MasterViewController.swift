//
//  MasterViewController.swift
//  Encounter Helper
//
//  Created by Wayne Ohmer on 8/18/19.
//  Copyright © 2019 Tryal by Fyre. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var filterdMonsters = [Monster]()
    var encounter = Encounter()
    let searchController = UISearchController(searchResultsController: nil)
    let titleButton =  UIButton(type: .custom)

    @IBOutlet var headerView: UIView!
    
    var monsters = [Monster]()
    var isEncounter:Bool { return monsters.count != Monster.sharedMonsters.count }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        if Monster.sharedMonsters.count == 0 {
            Monster.readMonsters()
        }
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Monsters"
        searchController.searchBar.tintColor = .white
        searchController.searchBar.barStyle = .black
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        self.tableView.estimatedRowHeight = 60
        self.tableView.tableFooterView = UIView()
        
        self.navigationItem.title = encounter.name
        self.monsters = encounter.monsters
        
        titleButton.frame = CGRect(x: 0, y: 0, width: 250, height: 40)
        titleButton.backgroundColor = UIColor(red: 35/255, green: 34/255, blue: 34/255, alpha: 1)
        titleButton.setTitle(self.encounter.name, for: .normal)
        titleButton.addTarget(self, action: #selector(flipTouched), for: .touchUpInside)
        self.navigationItem.titleView = titleButton

        //self.tableView.tableHeaderView = self.headerView
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }

    @IBAction func SaveTouched(_ sender: Any) {
        self.encounter.save()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func flipTouched() {
        monsters = isEncounter ? Monster.sharedMonsters : encounter.monsters
        //monsters.sort(by: {$0.challengeRating < $1.challengeRating })
        let title = isEncounter ?  self.encounter.name : "All"
        self.titleButton.setTitle(title, for: .normal)
        tableView.reloadData()
    }
    
    func selectMonsterWith(name:String ) {
        for (idx,monster) in isFiltering() ? filterdMonsters.enumerated() : monsters.enumerated()  {
            if monster.name == name {
                self.tableView.selectRow(at: IndexPath(row: idx, section: 0), animated: true, scrollPosition: .middle)
            }
        }
    }
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                
                controller.monster = isFiltering() ? filterdMonsters[indexPath.row] : monsters[indexPath.row]
                controller.masterVc = self
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filterdMonsters.count
        }
        return monsters.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellId = isEncounter ? "MonsterEncounterCell" : "MonsterListCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MonsterListCell

        let monster = isFiltering() ? filterdMonsters[indexPath.row] : monsters[indexPath.row]
        
        cell.monster = monster
        cell.encounter = encounter
        cell.isEncounter = isEncounter
        cell.updateCell()
        cell.addRemoveButton?.tag = indexPath.row
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return isEncounter
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.encounter.monsters.remove(at: indexPath.row)
            self.monsters = self.encounter.monsters
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } 
    }
    
    // MARK: - Private instance methods
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filterdMonsters = monsters.filter({( monster:Monster) -> Bool in
            return monster.name.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    @IBAction func tableButtonTouched(_ sender: UIButton) {
        if sender.title(for: .normal) == "+" {
            if isFiltering() {
                self.encounter.monsters.append(filterdMonsters[sender.tag])
            } else {
                self.encounter.monsters.append(monsters[sender.tag])
            }
            tableView.reloadRows(at: [IndexPath(item: sender.tag, section: 0)], with: .automatic)
        }
    }
    

}

extension MasterViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)

    }
}


