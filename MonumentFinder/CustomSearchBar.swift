//
//  CustomSearchBar.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 15.06.17.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit

@objc protocol CustomSearchBarDelegate {
    
    func searchFieldDidChange(searchText: String)
    
    func cancelButtonPressed()
    
}

@IBDesignable

class CustomSearchBar: UIView, UITextFieldDelegate {
    
    @IBOutlet var customSearchBarDelegate: CustomSearchBarDelegate?
    
    @IBOutlet weak var searchField: UITextField!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBAction func cancelAction(_ sender: Any) {
        
        customSearchBarDelegate?.cancelButtonPressed()
    }
    
    let nibName = "CustomSearchBar"
    var view: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        xibSetup()
        searchField.delegate = self
        searchField.addTarget(self, action: #selector(searchFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        searchField.clearButtonMode = .whileEditing
        
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    
    func xibSetup() {
       
        view = Bundle(for: type(of: self)).loadNibNamed(nibName, owner: self, options: nil)!.first as! UIView
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = UIColor.clear
        addSubview(view)
        
    }
    
    
    override func draw(_ rect: CGRect) {
        
        let lineWidth: CGFloat = 2.5
        
        let startPoint = CGPoint(x: 0, y: frame.size.height - lineWidth * 0.5)
        let endPoint = CGPoint(x: frame.size.width, y: frame.size.height - lineWidth * 0.5)
        
        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = defaultColor.cgColor
        shapeLayer.lineWidth = lineWidth
        
        layer.addSublayer(shapeLayer)
        self.backgroundColor = UIColor.clear
        
        // super.draw(rect)
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("textFieldDidBeginEditing")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditing")
    }
    
    @objc func searchFieldDidChange(_ searchField: UITextField) {
        
        customSearchBarDelegate?.searchFieldDidChange(searchText: searchField.text!)
        
    }

    
}
