//
//  DetailViewController.swift
//  Encounter Helper
//
//  Created by Wayne Ohmer on 8/18/19.
//  Copyright © 2019 Tryal by Fyre. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var hitPointsLabel: UILabel!
    @IBOutlet weak var armorClassLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var speedLabel: UILabel!
    
    @IBOutlet weak var sensesLabel: UILabel!
    @IBOutlet weak var strButton: UIButton!
    @IBOutlet weak var conButton: UIButton!
    @IBOutlet weak var dexButton: UIButton!
    @IBOutlet weak var intButton: UIButton!
    @IBOutlet weak var wisButton: UIButton!
    @IBOutlet weak var chaButton: UIButton!

    var monster:Monster?
    
    func configureView() {
        if let monster = self.monster {
            navigationItem.title = monster.name
            descriptionLabel.text = monster.meta
            hitPointsLabel.text = "\(monster.hitPoints)"
            armorClassLabel.text = "\(monster.armorClass)"
            
            imageView.image = monster.image
            imageView.layer.borderColor = UIColor.black.cgColor
            imageView.layer.borderWidth = 2.0
            hitPointsLabel.layer.borderColor = UIColor.black.cgColor
            hitPointsLabel.layer.borderWidth = 2.0
            
            speedLabel.text = monster.speed
            sensesLabel.text = monster.senses
            
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
    
    func fixButtonTitleWith(attribute:String, score:Int, save:Int) -> String {
        let modifier = (score-10)/2
        let sign = modifier > 0 ? "+": ""
        var title =  modifier != 0 ? "\(attribute) \(score) \(sign)\(modifier)" : "\(attribute) \(score)"
        if save != 0 {
            title = "\(title)/\(save)"
        }
        return title
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ActionTableViewController {
            vc.monster = self.monster ?? Monster()
        }
    }
    
   
}

