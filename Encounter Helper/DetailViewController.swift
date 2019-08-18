//
//  DetailViewController.swift
//  Encounter Helper
//
//  Created by Wayne Ohmer on 8/18/19.
//  Copyright © 2019 Tryal by Fyre. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var hitPointsLabel: UILabel!
    @IBOutlet weak var armorClassLabel: UILabel!
    @IBOutlet weak var traits: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    var monster:Monster?
    
    func configureView() {
        if let monster = self.monster {
            nameLabel.text = monster.monsterModel.name
            descriptionLabel.text = monster.metaMonster.meta
            hitPointsLabel.text = "\(monster.monsterModel.hit_points)"
            armorClassLabel.text = "\(monster.monsterModel.armor_class)"
            
            let htmlData = NSString(string: monster.metaMonster.Traits ?? "").data(using: String.Encoding.unicode.rawValue)
            let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
            let attributedString = try! NSAttributedString(data: htmlData!, options: options, documentAttributes: nil)
            traits.attributedText = attributedString
            imageView.image = UIImage(data: try! Data(contentsOf: URL(string:monster.metaMonster.img_url!)!))
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

   
}

