//
//  DetailViewController.swift
//  Encounter Helper
//
//  Created by Wayne Ohmer on 8/18/19.
//  Copyright © 2019 Tryal by Fyre. All rights reserved.
//

import UIKit

protocol LogManager {
    func logMessage(message: String)
}

class DetailViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LogManager {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var hitPointsLabel: UILabel!
    @IBOutlet weak var hitPointView: UIView!
    @IBOutlet weak var armorClassLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var noImage: UIImageView!
    @IBOutlet weak var imageBorder: UIView!

    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var damageResistLabel: UILabel!
    @IBOutlet weak var damageImmuneLabel: UILabel!
    @IBOutlet weak var conditionImmuneLabel: UILabel!
    @IBOutlet weak var conditionsLabel: UILabel!

    @IBOutlet weak var damageResistStack: UIStackView!
    @IBOutlet weak var damageImmuneStack: UIStackView!
    @IBOutlet weak var conditionImmuneStack: UIStackView!

    @IBOutlet weak var nameField: UITextField!

    @IBOutlet weak var sensesLabel: UILabel!
    @IBOutlet weak var strButton: UIButton!
    @IBOutlet weak var conButton: UIButton!
    @IBOutlet weak var dexButton: UIButton!
    @IBOutlet weak var intButton: UIButton!
    @IBOutlet weak var wisButton: UIButton!
    @IBOutlet weak var chaButton: UIButton!
    @IBOutlet weak var fadeView: UIView!

    @IBOutlet var diceButton: UIBarButtonItem!
    @IBOutlet var duplicateButton: UIBarButtonItem!
    @IBOutlet var condictionsButton: UIBarButtonItem!
    @IBOutlet var startButton: UIBarButtonItem!
    @IBOutlet var massSpellButton: UIBarButtonItem!
    @IBOutlet var saveButton: UIBarButtonItem!

    var monster: Monster?
    var masterVc: MasterViewController?
    var encounter: Encounter { return masterVc?.encounter ?? Encounter() }
    var ecounterBarButtons: [UIBarButtonItem] { return [startButton, condictionsButton, diceButton, massSpellButton]}
    var noEcounterBarButtons: [UIBarButtonItem] { return [startButton, duplicateButton, saveButton]}
    var allBarButtons = [UIBarButtonItem]()
    var actionVc = ActionTableViewController()
    let titleButton =  UIButton(type: .custom)

    func configureView() {
        if let monster = self.monster {
            nameField.text = monster.name
            descriptionLabel.text = monster.meta
            conditionsLabel.text = monster.conditions
            self.updateHP()

            hitPointView.clipsToBounds = false
            hitPointView.layer.cornerRadius = 7
            hitPointView.layer.shadowColor = UIColor.red.cgColor
            hitPointView.layer.shadowOpacity = 1.0
            hitPointView.layer.shadowOffset = CGSize(width: 0, height: 0)
            hitPointView.layer.shadowRadius = 5

            armorClassLabel.text = "\(monster.armorClass)"

            imageView.image = monster.image
            imageBorder.layer.borderWidth = 1
            imageBorder.layer.borderColor = UIColor.darkGray.cgColor

            speedLabel.text = monster.speed
            sensesLabel.text = monster.senses
            if monster.damageResistances != "" {
                damageResistStack.isHidden = false
                damageResistLabel.text = monster.damageResistances
            } else {
                damageResistStack.isHidden = true
            }

            if monster.damageImmunities != "" {
                damageImmuneStack.isHidden = false
                damageImmuneLabel.text = monster.damageImmunities
            } else {
                damageImmuneStack.isHidden = true
            }

            if monster.conditionImmunities != "" {
                conditionImmuneStack.isHidden = false
                conditionImmuneLabel.text = monster.conditionImmunities
            } else {
                conditionImmuneStack.isHidden = true
            }

            strButton.setTitle(self.fixButtonTitleWith(attribute: "STR", score: monster.strength, save: monster.strengthSave), for: .normal)
            intButton.setTitle(self.fixButtonTitleWith(attribute: "INT", score: monster.intelligence, save: monster.intelligenceSave), for: .normal)
            dexButton.setTitle(self.fixButtonTitleWith(attribute: "DEX", score: monster.dexterity, save: monster.dexteritySave), for: .normal)
            conButton.setTitle(self.fixButtonTitleWith(attribute: "CON", score: monster.constitution, save: monster.constitutionSave), for: .normal)
            wisButton.setTitle(self.fixButtonTitleWith(attribute: "WIS", score: monster.wisdom, save: monster.wisdomSave), for: .normal)
            chaButton.setTitle(self.fixButtonTitleWith(attribute: "CHA", score: monster.charisma, save: monster.charismaSave), for: .normal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItems = noEcounterBarButtons
        titleButton.frame = CGRect(x: 0, y: 0, width: 250, height: 40)
        titleButton.backgroundColor = UIColor(red: 35/255, green: 34/255, blue: 34/255, alpha: 1)
        titleButton.setTitle("Round \(encounter.round)", for: .normal)
        titleButton.addTarget(self, action: #selector(roundTouched), for: .touchUpInside)
        self.navigationItem.titleView = titleButton
        configureView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.monster == nil {
            self.view.bringSubviewToFront(fadeView)
            self.fadeView.isHidden = false
            self.fadeView.alpha = 1
        } else {
            self.view.bringSubviewToFront(fadeView)
            self.fadeView.isHidden = false
            self.fadeView.alpha = 1
            UIView.animate(withDuration: 0.3, animations: {
                self.fadeView.alpha = 0
            })
        }
        if let vc = masterVc {
            self.startButton.title = vc.encounter.isStarted ? "Finish" : "Start"
            self.navigationItem.rightBarButtonItems = vc.encounter.isStarted ? ecounterBarButtons : noEcounterBarButtons
        }
        self.navigationItem.title = "Round \(encounter.round)"
    }

    func fixButtonTitleWith(attribute: String, score: Int, save: Int?) -> String {
        let modifier = (score-10)/2
        let sign = modifier > 0 ? "+": ""
        var title =  modifier != 0 ? "\(attribute) \(score) \(sign)\(modifier)" : "\(attribute) \(score)"
        if save != nil {
            title = "\(title)/\(save!)"
        }
        return title
    }

    @objc func roundTouched() {
        encounter.round += 1
        titleButton.setTitle("Round \(encounter.round)", for: .normal)
    }

    func updateHP() {
        self.hitPointsLabel.text = "\(monster?.hitPoints ?? 0)"
        self.hitPointsLabel.textColor = monster?.damageColor
        self.noImage.isHidden = (monster?.hitPoints ?? 0) > 0
        self.view.alpha = (monster?.hitPoints ?? 0) <= 0 ? 0.5 : 1
    }

    func updateMasterVc() {
        self.masterVc?.tableView.reloadRows(at: self.masterVc?.tableView.indexPathsForSelectedRows ?? [IndexPath](), with: .none)
        self.masterVc?.selectMonsterWith(name: monster?.name ?? "")

    }

    func logMessage(message: String) {
        self.monster?.addLog(desc: "Round \(encounter.round) \(message)")
        self.actionVc.tableView.reloadData()
    }

    // MARK: - Navigation
    @IBAction func dupTouched(_ sender: UIBarButtonItem) {

        let newMonster = Monster(model: self.monster?.monsterModel ?? MonsterModel())
        var components = newMonster.name.split(separator: " ")
        if var num = Int(String(components.last ?? "")) {
            num += 1
            components.removeLast()
            newMonster.monsterModel.name = "\(components.joined(separator: " ")) \(num)"
            while self.encounter.monsters.filter({ $0.name == newMonster.name }).count > 0 {
                num += 1
                newMonster.monsterModel.name = "\(components.joined(separator: " ")) \(num)"
            }
        } else {
            self.monster?.monsterModel.name = "\(newMonster.name) 1"
            newMonster.monsterModel.name = "\(newMonster.name) 2"
        }
        self.encounter.monsters.append(newMonster)
        self.encounter.monsters.sort(by: { $0.name < $1.name })
        self.masterVc?.monsters = encounter.monsters
        self.masterVc?.tableView.reloadData()
        self.monster = newMonster
        self.masterVc?.selectMonsterWith(name: newMonster.name)
    }

    @IBAction func saveTouched(_ sender: UIBarButtonItem) {
        self.monster?.saveToCloudWith(name: "\(self.encounter.name)-\(self.monster?.name ?? "")")
    }

    @IBAction func startTouched(_ sender: UIBarButtonItem) {
        if let vc = masterVc {
            vc.encounter.isStarted = !vc.encounter.isStarted
            if vc.encounter.isStarted {
                let alertController = UIAlertController(title: "Randomize HP?", message: "", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                    for monster in self.encounter.monsters {
                        monster.randomizeHP()
                    }
                    self.updateHP()
                }))
                alertController.addAction(UIAlertAction(title: "No", style: .default))
                self.present(alertController, animated: true)

                self.navigationItem.rightBarButtonItems = ecounterBarButtons
            } else {
                self.navigationItem.rightBarButtonItems = noEcounterBarButtons
            }
            self.startButton.title = encounter.isStarted ? "Finish" : "Start"
            vc.encounter.round = 1
            self.navigationItem.title = "Round \(encounter.round)"

        }
    }

    @IBAction func massSpellTouched(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Mass Spell", message: "", preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: Attribute.Strength.rawValue, style: .default, handler: { _ in
            self.performSegue(withIdentifier: "massSpell", sender: Attribute.Strength)
        }))
        alertController.addAction(UIAlertAction(title: Attribute.Dexterity.rawValue, style: .default, handler: { _ in
            self.performSegue(withIdentifier: "massSpell", sender: Attribute.Dexterity)
        }))
        alertController.addAction(UIAlertAction(title: Attribute.Constitution.rawValue, style: .default, handler: { _ in
            self.performSegue(withIdentifier: "massSpell", sender: Attribute.Constitution)
        }))
        alertController.addAction(UIAlertAction(title: Attribute.Intelligence.rawValue, style: .default, handler: { _ in
            self.performSegue(withIdentifier: "massSpell", sender: Attribute.Intelligence)
        }))
        alertController.addAction(UIAlertAction(title: Attribute.Wisdom.rawValue, style: .default, handler: { _ in
            self.performSegue(withIdentifier: "massSpell", sender: Attribute.Wisdom)
        }))
        alertController.addAction(UIAlertAction(title: Attribute.Charisma.rawValue, style: .default, handler: { _ in
            self.performSegue(withIdentifier: "massSpell", sender: Attribute.Charisma)
        }))

        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = self.massSpellButton
        }
        self.present(alertController, animated: true, completion: nil)

    }

    @IBAction func conditionsTouched(_ sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "conditionsDesc", sender: nil)
    }

    @IBAction func imageTouched() {
        let alertController = UIAlertController(title: "Add Image", message: "", preferredStyle: .actionSheet)

        func launchPicker(sourceType: UIImagePickerController.SourceType) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = sourceType
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }

        alertController.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                launchPicker(sourceType: .camera)
            }
        }))

        alertController.addAction(UIAlertAction(title: "Choose Photo From Library", style: .default, handler: { _ in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                launchPicker(sourceType: .photoLibrary)
            }
        }))

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.imageView
            popoverController.sourceRect = (popoverController.sourceView?.bounds)!
        }
        self.present(alertController, animated: true, completion: nil)

    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.monster?.image = image
            self.imageView.image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.nameField {
            self.monster?.monsterModel.name = textField.text ?? ""
            self.masterVc?.tableView.reloadData()
        }
        textField.resignFirstResponder()
        return true
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        func prepSave(vc: DiceController, name: String, save: Int?, stat: Int ) {
            vc.rollName = name
            vc.fyreDice = FyreDice()
            vc.fyreDice.dice = [20: 1]
            vc.saveMod = save ?? Int((stat - 10)/2)
            vc.checkMod = Int((stat - 10)/2)
            vc.fyreDice.modifier = vc.saveMod ?? 0
            vc.logManager = self
        }

        switch segue.identifier {
        case "actionEmbed":
            if let vc = segue.destination as? ActionTableViewController {
                vc.monster = self.monster ?? Monster()
                vc.monsterVc = self
                actionVc = vc
            }
        case "strSave":
            if let vc = segue.destination as? DiceController {
                guard let monster = monster else { return }
                prepSave(vc: vc, name: "Strength Save", save: monster.strengthSave, stat: monster.strength)

            }
        case "dexSave":
            if let vc = segue.destination as? DiceController {
                guard let monster = monster else { return }
                prepSave(vc: vc, name: "Dexterity Save", save: monster.dexteritySave, stat: monster.dexterity)

            }
        case "conSave":
            if let vc = segue.destination as? DiceController {
                guard let monster = monster else { return }
                prepSave(vc: vc, name: "Constitution Save", save: monster.constitutionSave, stat: monster.constitution)

            }
        case "intSave":
            if let vc = segue.destination as? DiceController {
                guard let monster = monster else { return }
                prepSave(vc: vc, name: "Intelligence Save", save: monster.intelligenceSave, stat: monster.intelligence)

            }
        case "wisSave":
            if let vc = segue.destination as? DiceController {
                guard let monster = monster else { return }
                prepSave(vc: vc, name: "Wisdom Save", save: monster.wisdomSave, stat: monster.wisdom)

            }
        case "chaSave":
            if let vc = segue.destination as? DiceController {
                guard let monster = monster else { return }
                prepSave(vc: vc, name: "Charisma Save", save: monster.charismaSave, stat: monster.charisma)

            }
        case "editHP":
            if let vc = segue.destination as? HitPointEditorController {
                vc.monsterVc = self
            }
        case "Conditions":
            if let vc = segue.destination as? ConditionsController {
                vc.monsterVc = self
            }
        case "massSpell":
            if let vc = segue.destination as? MassSpellController {
                vc.encounter = self.encounter
                vc.attribute = sender as? Attribute ?? Attribute.Strength
            }
        case "conditionsDesc":
            if let vc = segue.destination as? ConditionsDescController {
                vc.conditions = Array(monster?.monsterModel.conditions ?? Set<String>())
            }

        default:
            break
        }
    }

}
