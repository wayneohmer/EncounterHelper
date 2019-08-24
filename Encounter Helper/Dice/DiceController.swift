//
//  ViewController.swift
//  Fyre Dice
//
//  Created by Wayne Ohmer on 10/7/17.
//  Copyright © 2017 Wayne Ohmer. All rights reserved.
//

import UIKit
import AudioToolbox

class DiceController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var resultDisplayLabel: UILabel!
    @IBOutlet weak var rollValueLabel: UILabel!
    @IBOutlet weak var advantageSwitch: AdvantageSwitch!
    @IBOutlet weak var disadvantageSwitch: AdvantageSwitch!
   
    @IBOutlet weak var rollButton: UIButton!
    
    @IBOutlet weak var d4Button: UIButton!
    @IBOutlet weak var d6Button: UIButton!
    @IBOutlet weak var d8Button: UIButton!
    @IBOutlet weak var d10Button: UIButton!
    @IBOutlet weak var d12Button: UIButton!
    @IBOutlet weak var d20Button: UIButton!
    @IBOutlet weak var d100Button: UIButton!
    
    @IBOutlet weak var plus1Button: UIButton!
    @IBOutlet weak var plus2Button: UIButton!
    @IBOutlet weak var plus3Button: UIButton!
    @IBOutlet weak var plus4Button: UIButton!
    @IBOutlet weak var plus5Button: UIButton!
    @IBOutlet weak var plus6Button: UIButton!
    @IBOutlet weak var plus7Button: UIButton!
    @IBOutlet weak var plus8Button: UIButton!
    @IBOutlet weak var plus9Button: UIButton!
    @IBOutlet weak var plus10Button: UIButton!
    @IBOutlet weak var plus20Button: UIButton!
    @IBOutlet weak var plus30Button: UIButton!
    @IBOutlet weak var SaveCheckSwitch: UISegmentedControl!
    
    let deathSound = "DeathSound"
    let awwwSound = "Awww"
    let oneDieSound = "1die"
    let threeDieSound = "3dice"
    let tenDieSound = "10dice"
    
    var diceButtons = [UIButton]()
    var modifierButtons = [UIButton]()
    var soundUrls = [String:CFURL]()
    var hasRolled = false
    var currentHistoryIndex = 0
    var oopsStack = [Oops]()
    
    var rollName: String?
    var saveMod:Int?
    var checkMod:Int?
    var fyreDice = FyreDice()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel.text = self.rollName ?? ""
        self.makeSystemSoundUrls()
        self.advantageSwitch.companion = self.disadvantageSwitch
        self.disadvantageSwitch.companion = self.advantageSwitch
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateDisplay()
     }
    
    func makeSystemSoundUrls() {
        if let soundUrl = Bundle.main.url(forResource: self.deathSound, withExtension: "aif")  {
           self.soundUrls[self.deathSound] = soundUrl as CFURL
        }
        if let soundUrl = Bundle.main.url(forResource: self.awwwSound, withExtension: "aif") {
            self.soundUrls[self.awwwSound] = soundUrl as CFURL
        }
        if let soundUrl = Bundle.main.url(forResource: self.oneDieSound, withExtension: "aif") {
            self.soundUrls[self.oneDieSound] = soundUrl as CFURL
        }
        if let soundUrl = Bundle.main.url(forResource: self.threeDieSound, withExtension: "aif") {
            self.soundUrls[self.threeDieSound] = soundUrl as CFURL
        }
        if let soundUrl = Bundle.main.url(forResource: self.tenDieSound, withExtension: "aif") {
            self.soundUrls[self.tenDieSound] = soundUrl as CFURL
        }
    }
  
    func fixAdvantageSwitches () {
        if self.fyreDice.isAdvantageAllowed {
            self.advantageSwitch.isEnabled = true
            self.disadvantageSwitch.isEnabled = true
            self.advantageSwitch.setOn(self.fyreDice.advantage, animated: true)
            self.disadvantageSwitch.setOn(self.fyreDice.disadvantage, animated: true)
        } else {
            self.advantageSwitch.isEnabled = false
            self.disadvantageSwitch.isEnabled = false
        }
    }
    func updateDisplay () {
        self.displayLabel.text = self.fyreDice.display
        self.resultDisplayLabel.text = self.fyreDice.resultDisplay
        self.rollValueLabel.text = self.fyreDice.rollValue != 0 ? "\(self.fyreDice.rollValue)" : " "
        
        self.rollButton.isEnabled = self.fyreDice.dice.count > 0
       
        self.fixAdvantageSwitches()

    }
    
    func swapSign(from:String, to new:String, in buttons:[UIButton]) {
        for button in buttons{
            let title = button.title(for: .normal)
            let newTitle = title?.replacingOccurrences(of: from, with: new)
            button.setTitle(newTitle, for: .normal)
        }
    }

    @IBAction func switchTouched(_ sender: AdvantageSwitch) {
        sender.fixCompanion()
        if sender == self.advantageSwitch {
            self.fyreDice.advantage = sender.isOn
        } else if sender == self.disadvantageSwitch {
            self.fyreDice.disadvantage = sender.isOn
        }
    }
    
    @IBAction func rollTouched() {
        self.oopsStack.append(Oops(fyreDice: FyreDice(with:self.fyreDice, includeResult:true), type: Oops.OopsType.roll))
        self.hasRolled = true
        self.fyreDice.roll()
        var soundURL:CFURL?
        if self.fyreDice.rollValue == self.fyreDice.max {
            soundURL = self.soundUrls[self.deathSound]
        } else if self.fyreDice.rollValue == self.fyreDice.min  {
            soundURL = self.soundUrls[self.awwwSound]
        } else if self.fyreDice.numberOfDice > 10 {
            soundURL = self.soundUrls[self.tenDieSound]
        } else if self.fyreDice.numberOfDice > 3 {
            soundURL = self.soundUrls[self.threeDieSound]
        } else {
            soundURL = self.soundUrls[self.oneDieSound]
        }
        if let soundURL = soundURL {
            var soundId = SystemSoundID(0)
            AudioServicesCreateSystemSoundID(soundURL, &soundId)
            AudioServicesPlaySystemSoundWithCompletion(soundId) {
                AudioServicesDisposeSystemSoundID(soundId)
            }
        }
        FyreDice.shardedHistory.append(FyreDice(with:self.fyreDice, includeResult:true))
        self.currentHistoryIndex = FyreDice.shardedHistory.count-1
        self.updateDisplay()
    }

    @IBAction func signTouched(_ sender: UIButton) {
        
        let buttonArray = self.modifierButtons + self.diceButtons
 
        if sender.title(for: .normal) == "+" {
            sender.setTitle("-", for: .normal)
            self.swapSign(from:"-", to: "+", in: buttonArray)
        } else {
            sender.setTitle("+", for: .normal)
            self.swapSign(from:"+", to: "-", in: buttonArray)
        }
    }
    
    @IBAction func clearTouched() {
        self.oopsStack.append(Oops(fyreDice: FyreDice(with:self.fyreDice, includeResult:true), type: Oops.OopsType.buttonTouch))

        self.fyreDice.clear()
        self.updateDisplay()
    }
    
    @IBAction func dieTouched(_ sender: UIButton) {
        self.oopsStack.append(Oops(fyreDice: FyreDice(with:self.fyreDice, includeResult:true), type: Oops.OopsType.buttonTouch))
        if hasRolled {
            self.fyreDice.clear()
            self.hasRolled = false
        }
        let components = sender.title(for: .normal)?.components(separatedBy: "d")
        if components?.count == 2 {
            self.fyreDice.add(multipier: Int(components?[0] ?? "0") ?? 0 , d: Int(components?[1] ?? "0") ?? 0)
        }
        self.updateDisplay()
    }
    
    @IBAction func modifierTouched(_ sender: UIButton) {
        self.oopsStack.append(Oops(fyreDice: FyreDice(with:self.fyreDice, includeResult:true), type: Oops.OopsType.buttonTouch))
        let modifier = Int(sender.title(for: .normal) ?? "0") ?? 0
        self.fyreDice.modifier += modifier
        self.updateDisplay()
    }
    
    @IBAction func historyBackTouhced() {
        if self.currentHistoryIndex > 0 {
            self.currentHistoryIndex -= 1
            self.fyreDice = FyreDice(with:FyreDice.shardedHistory[self.currentHistoryIndex], includeResult:true)
            self.updateDisplay()
        }
    }
    
    @IBAction func historyForwardouhced() {
        if self.currentHistoryIndex < FyreDice.shardedHistory.count-1 {
            self.currentHistoryIndex += 1
            self.fyreDice = FyreDice(with:FyreDice.shardedHistory[self.currentHistoryIndex], includeResult:true)
            self.updateDisplay()
        }
    }
    
    @IBAction func oopsTouched() {
        if let oops = oopsStack.last {
            switch oops.type {
            case .buttonTouch:
                self.fyreDice = FyreDice(with:oops.fyreDice, includeResult:true)
                self.updateDisplay()
            case .roll:
                self.fyreDice = FyreDice(with:oops.fyreDice, includeResult:true)
                self.updateDisplay()
                if self.currentHistoryIndex > 0 {
                    FyreDice.shardedHistory.removeLast()
                    self.currentHistoryIndex -= 1
                }

            case .saveDelete:
                break
            case .save:
                break
            }
            oopsStack.removeLast()
        }
    }
    @IBAction func saveCheckTouhced(_ sender: UISegmentedControl) {
        
        self.fyreDice.modifier = sender.selectedSegmentIndex == 0 ? self.saveMod ?? 0 : self.checkMod ?? 0
        self.updateDisplay()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }


}

