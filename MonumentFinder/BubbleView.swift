//
//  MaxVisiblitàView.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 11/01/2017.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit

class BubbleView: UIView {
    let defaults = UserDefaults.standard
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        //self.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        self.cornerRadius = 5
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.init(netHex: 0x95989A).cgColor

        
        //Label
        let descrizione = UILabel()
        descrizione.frame = CGRect(x: 0, y: 12, width: self.frame.width, height: 20)
        descrizione.textAlignment = NSTextAlignment.center
        descrizione.text = "Visibiltà massima (metri)"
        descrizione.textColor = defaultColor
        descrizione.font = UIFont(name: "HelveticaNeue-Thin", size: 18) ?? UIFont.systemFont(ofSize: 18)
        self.addSubview(descrizione)
        
        
        // Aggiungi lo slider
        
        let altezza: CGFloat = 20.0
        let slider = CustomSlider(frame: CGRect(x: 15, y: rect.midY - altezza / 2, width: rect.width - 30, height: altezza))
        slider.isContinuous = true
        slider.tintColor = UIColor(netHex: 0xB21818)
        slider.minimumValue = 0
        slider.maximumValue = 5000
        
        
        
        if defaults.object(forKey: "maxVisibilità") != nil {

            slider.value = defaults.value(forKey: "maxVisibilità") as! Float
        } else {
            let defaultValue = 500;
            defaults.set(defaultValue, forKey: "maxVisibilità")
            slider.value = Float(defaultValue)
        }
        slider.addTarget(self, action: #selector(valoreCambiato(_ :)), for: .touchUpInside)
        self.addSubview(slider)
    }
    
    func valoreCambiato(_ sender: CustomSlider) {
        defaults.set(sender.value, forKey: "maxVisibilità")
    }
}
