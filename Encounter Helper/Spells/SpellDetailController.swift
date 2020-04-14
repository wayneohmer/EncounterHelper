//
//  SpellDetailController.swift
//  Encounter Helper
//
//  Created by Wayne Ohmer on 9/22/19.
//  Copyright © 2019 Tryal by Fyre. All rights reserved.
//

import UIKit

class SpellDetailController: UIViewController {

    var spell: Spell?

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var rangeLabel: UILabel!
    @IBOutlet weak var castlingTimeLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var descriptionView: UITextView!
    @IBOutlet weak var durationLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let spell = spell, let details = spell.model.desc {

            nameLabel.text = spell.name
            nameLabel.layer.cornerRadius = 8

            rangeLabel.text = spell.model.range
            castlingTimeLabel.text = spell.model.castingTime
            levelLabel.text = spell.model.level
            durationLabel.text = "\(spell.concentration ? "Concentration -" : "") \(spell.model.duration ?? "") "

            let htmlData = NSString(string: details).data(using: String.Encoding.unicode.rawValue)
            let options = [NSAttributedString.DocumentReadingOptionKey.documentType:
                NSAttributedString.DocumentType.html]
            do {
                let attributedString = try NSMutableAttributedString(data: htmlData ?? Data(),
                                                                     options: options,
                                                                     documentAttributes: nil)
                attributedString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], range: NSRange(location: 0, length: attributedString.length))

                attributedString.enumerateAttribute(.font, in: NSRange(0..<attributedString.length)) { value, range, _ in
                    if let font = value as? UIFont {
                        var fontMetrics = UIFontMetrics(forTextStyle: .body)
                        if font.fontDescriptor.symbolicTraits.contains(.traitBold) {
                            fontMetrics = UIFontMetrics(forTextStyle: .title2)
                        }
                        let size = fontMetrics.scaledFont(for: UIFont.systemFont(ofSize: 20)).pointSize
                        let newFont = UIFont(name: font.fontName, size: size) ?? font
                        attributedString.removeAttribute(.font, range: range)
                        attributedString.addAttribute(.font, value: newFont, range: range)
                    }
                }

                self.descriptionView.attributedText = attributedString
                self.descriptionView.layer.cornerRadius = 8
            } catch {

            }

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
