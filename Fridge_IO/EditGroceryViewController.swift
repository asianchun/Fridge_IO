//
//  EditGroceryViewController.swift
//  Fridge_IO
//
//  Created by Hong Yi on 10/5/2023.
//

import UIKit

class EditGroceryViewController: UIViewController {
    
    weak var databaseController: DatabaseProtocol?

    @IBOutlet weak var dateControl: UIDatePicker!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var typeControl: UIButton!
    
    let DAIRY = "Dairy"
    let FRUITS_AND_VEGETABLES = "Fruits & Veggies"
    let MEAT = "Meat"
    let SEAFOOD = "Seafood"
    let CONDIMENTS = "Condiments"
    let OTHER = "Other"
    
    var grocery: Grocery?
    var type: GroceryType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPopup()

        navigationItem.title = "Edit \(grocery?.name ?? "")"
        nameTextField.text = grocery?.name ?? ""
        amountTextField.text = grocery?.amount ?? ""
        dateControl.date = grocery?.expiry ?? Date()
        
        dateControl.semanticContentAttribute = .forceRightToLeft
        dateControl.subviews.first?.semanticContentAttribute = .forceRightToLeft
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        nameTextField.layer.borderWidth = 1
        nameTextField.layer.cornerRadius = 5
        nameTextField.layer.borderColor = UIColor(named: "buttons")?.cgColor
        
        amountTextField.layer.borderWidth = 1
        amountTextField.layer.cornerRadius = 5
        amountTextField.layer.borderColor = UIColor(named: "buttons")?.cgColor
    }
    
    @IBAction func save(_ sender: Any) {
        guard let name = nameTextField.text, let amount = amountTextField.text, let type = type else {
            return
        }
        
        let date = dateControl.date
        
        if name.isEmpty || amount.isEmpty {
            var errorMsg = "Please ensure all fields are filled : \n"
            
            if name.isEmpty {
                errorMsg += "- Must provide a name \n"
            }
            if amount.isEmpty {
                errorMsg += "- Must provide an amount \n"
            }
            
            displayMessage(title: "Not all fields filled", message: errorMsg)
            return
        }
        
        databaseController?.editGrocery(grocery: grocery!, name: name, type: type, expiry: date, amount: amount)
        navigationController?.popViewController(animated: true)
    }
    
    func setupPopup() {
        let optionClosure = {(action: UIAction) in
            switch action.title {
            case self.DAIRY:
                self.type = GroceryType(rawValue: 0)
            case self.FRUITS_AND_VEGETABLES:
                self.type = GroceryType(rawValue: 1)
            case self.MEAT:
                self.type = GroceryType(rawValue: 2)
            case self.SEAFOOD:
                self.type = GroceryType(rawValue: 3)
            case self.CONDIMENTS:
                self.type = GroceryType(rawValue: 4)
            case self.OTHER:
                self.type = GroceryType(rawValue: 5)
            default:
                print("Error")
            }
        }
        
        
        typeControl.menu = UIMenu(children: [
            createAction(DAIRY, handler: optionClosure),
            createAction(FRUITS_AND_VEGETABLES, handler: optionClosure),
            createAction(MEAT, handler: optionClosure),
            createAction(SEAFOOD, handler: optionClosure),
            createAction(CONDIMENTS, handler: optionClosure),
            createAction(OTHER, handler: optionClosure)
        ])
        
        typeControl.showsMenuAsPrimaryAction = true
        typeControl.changesSelectionAsPrimaryAction = true
    }
    
    func createAction(_ name: String, handler: @escaping UIActionHandler) -> UIAction {
        let action = UIAction(title: name, handler: handler)
        var tempType: GroceryType?
        
        switch name {
        case DAIRY:
             tempType = GroceryType(rawValue: 0)
        case FRUITS_AND_VEGETABLES:
            tempType = GroceryType(rawValue: 1)
        case MEAT:
            tempType = GroceryType(rawValue: 2)
        case SEAFOOD:
            tempType = GroceryType(rawValue: 3)
        case CONDIMENTS:
            tempType = GroceryType(rawValue: 4)
        case OTHER:
            tempType = GroceryType(rawValue: 5)
        default:
            print("Error")
        }
        
        if tempType == GroceryType(rawValue: grocery?.type ?? 0) {
            action.state = .on
            type = tempType
        }
        
        return action
    }
    
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message,
        preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
        handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
}
