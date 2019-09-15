//
//  BlackButton.swift
//  Encounter Helper
//
//  Created by Wayne Ohmer on 8/20/19.
//  Copyright © 2019 Tryal by Fyre. All rights reserved.
//

import UIKit

@IBDesignable
class BlackButton: UIButton {

    var storedColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
    var color: UIColor {
        set {
            self.layoutSubviews()
            self.storedColor = newValue
        }
        get {
            return storedColor

        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        var gradientColors: [CGColor] = [UIColor.black.cgColor]

        var red: CGFloat = 0
        var blue: CGFloat = 0
        var green: CGFloat = 0
        var alpha: CGFloat = 0

        storedColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        for _ in 0...5 {
            //fmax assures result is > 0
            red = fmax(CGFloat(red) - 0.3, 0)
            green = fmax(CGFloat(green) - 0.3, 0)
            blue = fmax(CGFloat(blue) - 0.3, 0)
            gradientColors.append(UIColor(red: red, green: green, blue: blue, alpha: 0.4).cgColor)

        }
        let glossColors: [CGColor] = [UIColor(white: 1.0, alpha: 0.1).cgColor,
                                     UIColor(white: 0.75, alpha: 0.0).cgColor,
                                     UIColor(white: 1.0, alpha: 0.1).cgColor ]
        let glossLocations: [NSNumber] = [0.5, 0.5, 1.0]
        let butttonGradient = CAGradientLayer()
        butttonGradient.frame = self.bounds
        butttonGradient.colors = gradientColors

        self.layer.insertSublayer(butttonGradient, at: 0)

        let glossLayer = CAGradientLayer()
        glossLayer.frame = self.bounds
        glossLayer.colors = glossColors
        glossLayer.locations = glossLocations
        self.layer.insertSublayer(glossLayer, at: 0)

        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 0, height: 0)

    }

}
