//
//  MasterViewController.swift
//  Encounter Helper
//
//  Created by Wayne Ohmer on 8/18/19.
//  Copyright © 2019 Tryal by Fyre. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController, UITextFieldDelegate {

    var detailViewController: DetailViewController?
    var parentVc: EncounterTableViewController?
    var filterdMonsters = [Monster]()
    var encounter = Encounter()
    let titleButton =  UIButton(type: .custom)
    var searchCRMin: Float { return Float(crMinField.text ?? "") ?? 0 }
    var searchCRMax: Float { return Float(crMaxField.text ?? "") ?? 999 }
    var selectedIndex = IndexPath(row: 0, section: 0)

    @IBOutlet var encounterHeaderView: UIView!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var searchName: UITextField!
    @IBOutlet weak var crMinField: UITextField!
    @IBOutlet weak var crMaxField: UITextField!
    @IBOutlet var saveButton: UIBarButtonItem!

    var monsters = [Monster]()
    var isEncounter: Bool { return monsters.count == encounter.monsters.count }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }

        self.tableView.estimatedRowHeight = 60
        self.tableView.tableFooterView = UIView()

        self.navigationItem.title = encounter.name
        self.monsters = encounter.monsters

        titleButton.frame = CGRect(x: 0, y: 0, width: 250, height: 40)
        titleButton.backgroundColor = UIColor(red: 35/255, green: 34/255, blue: 34/255, alpha: 1)
        titleButton.setTitle(self.encounter.name, for: .normal)
        titleButton.addTarget(self, action: #selector(flipTouched), for: .touchUpInside)
        self.navigationItem.titleView = titleButton

        if self.encounter.monsters.count == 0 {
            self.titleButton.setTitle("All", for: .normal)
            self.monsters = Array(Monster.sharedMonsters)
            monsters.sort(by: {
                if $0.challengeRating == $1.challengeRating {
                    return $0.name < $1.name
                } else {
                    return $0.challengeRating < $1.challengeRating
                }
            })
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        self.tableView.selectRow(at: self.selectedIndex, animated: true, scrollPosition: .top)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.performSegue(withIdentifier: "showDetail", sender: nil)
    }

    @IBAction func SaveTouched(_ sender: Any) {
        self.encounter.save()
        self.parentVc?.lastGroup = encounter.group
        self.parentVc?.tableView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }

    @objc func flipTouched() {
        self.headerView.endEditing(true)
        monsters = self.titleButton.title(for: .normal) != "All" ? Array(Monster.sharedMonsters) : encounter.monsters
        monsters.sort(by: {
            if $0.challengeRating == $1.challengeRating {
                return $0.name < $1.name
            } else {
                return $0.challengeRating < $1.challengeRating
            }
        })
        let title = isEncounter ?  self.encounter.name : "All"
        self.titleButton.setTitle(title, for: .normal)
        self.navigationItem.rightBarButtonItem = isEncounter ? self.saveButton : nil
        tableView.reloadData()
    }

    func selectMonsterWith(name: String ) {
        for (idx, monster) in isFiltering() ? filterdMonsters.enumerated() : monsters.enumerated() {
            if monster.name == name {
                self.tableView.selectRow(at: IndexPath(row: idx, section: 0), animated: true, scrollPosition: .middle)
            }
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        filterContentForSearchText(searchName.text ?? "", scope: "All")
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let nstring = textField.text as NSString? ?? ""
        let newString = nstring.replacingCharacters(in: range, with: string) as String
        if newString.count >= 3 {
            filterContentForSearchText(newString, scope: "All")
        }
        return true
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

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return isEncounter ? self.encounterHeaderView : self.headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if !isEncounter {
            return 95
        } else {
            return 50
        }
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        self.difficultyLabel.layer.cornerRadius = 7
        self.difficultyLabel.clipsToBounds = true
        self.difficultyLabel.text = "XP - \(encounter.monsters.map({$0.experience}).reduce(0, + )) - \(encounter.totalXP) - \(encounter.threshold) "
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.encounter.monsters.remove(at: indexPath.row)
            self.monsters = self.encounter.monsters
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.difficultyLabel.text = "XP - \(encounter.monsters.map({$0.experience}).reduce(0, + )) - \(encounter.totalXP) - \(encounter.threshold)"

        }
    }

    // MARK: - Private instance methods

    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return (searchName.text?.isEmpty ?? true && crMinField.text?.isEmpty ?? true && crMaxField.text?.isEmpty ?? true)
    }

    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filterdMonsters = monsters.filter({( monster: Monster) -> Bool in
            if monster.challengeRating >= searchCRMin && monster.challengeRating <= searchCRMax {
                if searchText != "" {
                    return monster.name.lowercased().contains(searchText.lowercased())
                } else {
                    return true
                }
            } else {
                return false
            }
        })

        tableView.reloadData()
    }
    func isFiltering() -> Bool {
        return !searchBarIsEmpty() && !isEncounter
    }

    @IBAction func tableButtonTouched(_ sender: UIButton) {
        if sender.title(for: .normal) == "+" {
            if isFiltering() {
                self.encounter.monsters.append(Monster(model: filterdMonsters[sender.tag].monsterModel))
            } else {
                self.encounter.monsters.append(Monster(model: monsters[sender.tag].monsterModel))
            }
            tableView.reloadRows(at: [IndexPath(item: sender.tag, section: 0)], with: .automatic)
        }
    }

}
