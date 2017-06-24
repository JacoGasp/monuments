//
//  SearchVC.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 13.06.17.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit

class SearchVC: UIViewController, UITableViewDelegate, UITableViewDataSource, CustomSearchBarDelegate {
    
    var dataArray = [Monumento?]()
    var filteredArray = [Monumento?]()
    var shouldShowSearchResults = false
    
    var risultatoRicerca: Monumento!
    
    
    var delegate: RisultatoRicercaDelegate? = nil

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var customSearchBar: CustomSearchBar!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        
        // Add keyboard observers
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Clear background color of tableView
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        
        customSearchBar.customSearchBarDelegate = self

        dataArray = monumenti.sorted{ $0.0.nome < $0.1.nome }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
    
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            
            self.customSearchBar.searchField.becomeFirstResponder()

        }
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    
    func searchFieldDidChange(searchText: String) {

        print(searchText)
        
        filteredArray = dataArray.filter({ (monumento) -> Bool in
            
            let nomeText: NSString = monumento!.nome as NSString
            return (nomeText.range(of: searchText, options: NSString.CompareOptions.caseInsensitive).location != NSNotFound)
            
        })
        
        // Reload the tableview.
        
        if searchText.isEmpty {
            shouldShowSearchResults = false
        } else {
            shouldShowSearchResults = true
        }
        
        tableView.reloadData()
        
    }
    
    
    func cancelButtonPressed() {
        print("Culo2")
        shouldShowSearchResults = false
        tableView.reloadData()
        dismissController()
    }
    
    
    // tableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if shouldShowSearchResults {
            if filteredArray.isEmpty {
                return 1
            } else {
                return filteredArray.count
            }
        } else {
            return dataArray.count
        }
    
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "idCell", for: indexPath)
        
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.font = defaultFont
        
        if shouldShowSearchResults {
            
            if filteredArray.isEmpty {
            
                cell.textLabel?.text = "Non trovato."
            
            } else {
             
                cell.textLabel?.text = filteredArray[indexPath.row]?.nome
           
            }
            
        } else {
           
            cell.textLabel?.text = dataArray[indexPath.row]?.nome
        
        }
        
        return cell
        
    }
    
    // Tap città
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        
        if shouldShowSearchResults {
            if !filteredArray.isEmpty {
                self.risultatoRicerca = filteredArray[indexPath.row]
                dismissController()
                self.delegate?.risultatoRicerca(monumento: risultatoRicerca)
            }
        } else {
            self.risultatoRicerca = dataArray[indexPath.row]
            dismissController()
            self.delegate?.risultatoRicerca(monumento: risultatoRicerca)
        }
        
    
        
    }
    
    // Resize tableView with keyboard

    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.tableView.convert(keyboardSize, from: nil)
            self.tableView.contentInset.bottom = keyboardSize.size.height
            self.tableView.scrollIndicatorInsets.bottom = keyboardSize.size.height
        }
    
    }
    
    
    func keyboardWillHide(notification: NSNotification) {
        tableView.convert(self.view.frame, from: nil)
        tableView.contentInset.bottom = 0.0
        tableView.scrollIndicatorInsets.bottom = 0.0
    }
    
    
    func dismissController() {
        
        self.customSearchBar.endEditing(true)
        self.dismiss(animated: true, completion: nil)
        print("Dismiss SearchVC\n")
    }

}


extension UISearchBar {
    
    private func getViewElement<T>(type: T.Type) -> T? {
        
        let svs = subviews.flatMap { $0.subviews }
        guard let element = (svs.filter { $0 is T }).first as? T else { return nil }
        return element
    }
    
    func getSearchBarTextField() -> UITextField? {
        
        return getViewElement(type: UITextField.self)
    }
    
    func getSearchBarLabel() -> UILabel? {
        return getViewElement(type: UILabel.self)
    }
    
    func setTextColor(color: UIColor) {
        
        if let textField = getSearchBarTextField() {
            textField.textColor = color
        }
    }
    
    func setPromptTextColor(color : UIColor) {
        if let label = getViewElement(type: UILabel.self) {
            label.textColor = color
        }
    }
    
    func setTextFieldColor(color: UIColor) {
        
        if let textField = getViewElement(type: UITextField.self) {
            switch searchBarStyle {
            case .minimal:
                textField.layer.backgroundColor = color.cgColor
                textField.layer.cornerRadius = 6
                
            case .prominent, .default:
                textField.backgroundColor = color
            }
        }
    }
    
    func setPlaceholderTextColor(color: UIColor) {
        
        if let textField = getSearchBarTextField() {
            textField.attributedPlaceholder = NSAttributedString(string: self.placeholder != nil ? self.placeholder! : "", attributes: [NSForegroundColorAttributeName: color])
        }
    }
    
    func setPlaceholderFont(font: UIFont) {
        if let textField = getSearchBarTextField() {
            textField.font = font
        }
    }
    
    func setPromptFont(font: UIFont) {
        if let label = getViewElement(type: UILabel.self) {
            label.font = font
        }
    }
    
    func setPromptVerticalPosition(distanceFromBar: CGFloat) {
        if let label = getViewElement(type: UILabel.self) {
            label.center = CGPoint(x: self.bounds.width / 2, y: distanceFromBar)
        }
    }
    

}
