//
//  HitPointEditorController.swift
//  Encounter Helper
//
//  Created by Wayne Ohmer on 8/24/19.
//  Copyright © 2019 Tryal by Fyre. All rights reserved.
//

import UIKit

class HitPointEditorController: UIViewController {

    @IBOutlet weak var hpLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    @IBAction func numTouched(_ sender: UIButton) {
        if let title = sender.title(for: .normal) {
            self.hpLabel.text = "\(self.hpLabel.text ?? "")\(title)"
        }
        
    }
    

}
