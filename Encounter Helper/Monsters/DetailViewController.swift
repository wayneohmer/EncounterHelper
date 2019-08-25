//
//  DetailViewController.swift
//  Encounter Helper
//
//  Created by Wayne Ohmer on 8/18/19.
//  Copyright © 2019 Tryal by Fyre. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var hitPointsLabel: UILabel!
    @IBOutlet weak var hitPointView: UIView!
    @IBOutlet weak var armorClassLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var damageResistLabel: UILabel!
    @IBOutlet weak var damageImmuneLabel: UILabel!
    @IBOutlet weak var conditionImmuneLabel: UILabel!
    
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
    
    var monster:Monster?
    var masterTableView:UITableView?
    var encounter:Encounter?
    var masterVc:MasterViewController?
    
    func configureView() {
        if let monster = self.monster {
            nameField.text = monster.name
            descriptionLabel.text = monster.meta ?? "Some shit"
            hitPointsLabel.text = "\(monster.hitPoints)"
            
            hitPointView.clipsToBounds = false
            hitPointView.layer.cornerRadius = 7
            hitPointView.layer.shadowColor = UIColor.red.cgColor
            hitPointView.layer.shadowOpacity = 1.0
            hitPointView.layer.shadowOffset = CGSize(width: 0, height: 0)
            hitPointView.layer.shadowRadius = 5

            armorClassLabel.text = "\(monster.armorClass)"
            
            imageView.image = monster.image
            imageView.clipsToBounds = false
            imageView.layer.cornerRadius = 7
            imageView.layer.shadowColor = UIColor.white.cgColor
            imageView.layer.shadowOpacity = 0.5
            imageView.layer.shadowOffset = CGSize(width: 3, height: 0)
            
         
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
        // Do any additional setup after loading the view, typically from a nib.
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
    }
    
    func fixButtonTitleWith(attribute:String, score:Int, save:Int?) -> String {
        let modifier = (score-10)/2
        let sign = modifier > 0 ? "+": ""
        var title =  modifier != 0 ? "\(attribute) \(score) \(sign)\(modifier)" : "\(attribute) \(score)"
        if save != nil {
            title = "\(title)/\(save!)"
        }
        return title
    }
    // MARK: - Navigation
    @IBAction func dupTouched(_ sender: UIBarButtonItem) {
        let newMonster = Monster(model: self.monster?.monsterModel ?? MonsterModel())
        newMonster.monsterModel.name = "\(newMonster.name) 1"
        self.encounter?.monsters.append(newMonster)
        self.masterVc?.monsters = encounter?.monsters ?? [Monster]()
        self.masterTableView?.reloadData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.nameField {
            self.monster?.monsterModel.name = textField.text ?? ""
            self.masterTableView?.reloadData()
        }
        textField.resignFirstResponder()
        return true
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        func prepSave(vc:DiceController, name:String, save:Int?, stat:Int ){
            vc.rollName = name
            vc.fyreDice = FyreDice()
            vc.fyreDice.dice = [20 : 1]
            vc.saveMod = save ?? Int((stat - 10)/2)
            vc.checkMod = Int((stat - 10)/2)
            vc.fyreDice.modifier = vc.saveMod ?? 0
        }
        
        switch segue.identifier {
        case "actionEmbed":
            if let vc = segue.destination as? ActionTableViewController {
                vc.monster = self.monster ?? Monster()
            }
        case "strSave":
            if let vc = segue.destination as? DiceController {
                guard let monster = monster else { return }
                prepSave(vc: vc, name: "Strength", save: monster.strengthSave, stat: monster.strength)

            }
        case "dexSave":
            if let vc = segue.destination as? DiceController {
                guard let monster = monster else { return }
                prepSave(vc: vc, name: "Dexterity", save: monster.dexteritySave, stat: monster.dexterity)
                
            }
        case "conSave":
            if let vc = segue.destination as? DiceController {
                guard let monster = monster else { return }
                prepSave(vc: vc, name: "Constitution", save: monster.constitutionSave, stat: monster.constitution)
                
            }
        case "intSave":
            if let vc = segue.destination as? DiceController {
                guard let monster = monster else { return }
                prepSave(vc: vc, name: "Intelligence", save: monster.intelligenceSave, stat: monster.intelligence)
                
            }
        case "wisSave":
            if let vc = segue.destination as? DiceController {
                guard let monster = monster else { return }
                prepSave(vc: vc, name: "Wisdom", save: monster.wisdomSave, stat: monster.wisdom)
                
            }
        case "chaSave":
            if let vc = segue.destination as? DiceController {
                guard let monster = monster else { return }
                prepSave(vc: vc, name: "Charisma", save: monster.charismaSave, stat: monster.charisma)
                
            }
        default:
            break
        }
    }
    
   
}

