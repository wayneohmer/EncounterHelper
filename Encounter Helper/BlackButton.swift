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

    override func layoutSubviews() {
        super.layoutSubviews()
        var gradientColors:[CGColor] = [UIColor.black.cgColor]
        
        var red = CGFloat(1.0)
        var green = CGFloat(1.0)
        var blue = CGFloat(1.0)

        for _ in 0...5 {
            //fmax assures result is > 0
            red = fmax(CGFloat(red) - 0.3,0)
            green = fmax(CGFloat(green) - 0.3,0)
            blue = fmax(CGFloat(blue) - 0.3,0)
            gradientColors.append(UIColor(red: red, green: green, blue: blue, alpha: 0.4).cgColor)
            
        }
        let glossColors:[CGColor] = [UIColor(white: 1.0, alpha: 0.1).cgColor,
                                     UIColor(white: 0.75, alpha: 0.0).cgColor,
                                     UIColor(white: 1.0, alpha: 0.1).cgColor,]
        let glossLocations:[NSNumber] = [0.5,0.5,1.0]
        let butttonGradient = CAGradientLayer()
        butttonGradient.frame = self.bounds;
        butttonGradient.colors = gradientColors

        self.layer.insertSublayer(butttonGradient, at:0)

        let glossLayer = CAGradientLayer()
        glossLayer.frame = self.bounds
        glossLayer.colors = glossColors
        glossLayer.locations = glossLocations
        self.layer.insertSublayer(glossLayer, at:0)

        self.layer.cornerRadius = 10.0
        self.clipsToBounds = false
        self.layer.shadowColor = UIColor.white.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 3, height: 2)

    }
    

}
