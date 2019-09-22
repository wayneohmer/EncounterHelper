//
//  SpellDetailController.swift
//  Encounter Helper
//
//  Created by Wayne Ohmer on 9/22/19.
//  Copyright © 2019 Tryal by Fyre. All rights reserved.
//

import UIKit

class SpellDetailController: UIViewController {

    var spell: SpellModel?
    @IBOutlet weak var descriptionView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let spell = spell, let details = spell.desc {
            let htmlData = NSString(string: details).data(using: String.Encoding.unicode.rawValue)
            let options = [NSAttributedString.DocumentReadingOptionKey.documentType:
                NSAttributedString.DocumentType.html]
            let attributedString = try? NSMutableAttributedString(data: htmlData ?? Data(),
                                                                  options: options,
                                                                  documentAttributes: nil)
            self.descriptionView.attributedText = attributedString
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
