//
//  AddGroceriesViewController.swift
//  Fridge_IO
//
//  Created by Hong Yi on 2/5/2023.
//

import UIKit

class AddGroceryViewController: UIViewController {

    //Link to the database
    weak var databaseController: DatabaseProtocol?
    
    //Outlets
    @IBOutlet weak var dateControl: UIDatePicker!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var amountField: UITextField!
    @IBOutlet weak var typeControl: UIButton!
    
    //Constants
    let DAIRY = "Dairy"
    let FRUITS_AND_VEGETABLES = "Fruits & Veggies"
    let MEAT = "Meat"
    let SEAFOOD = "Seafood"
    let CONDIMENTS = "Condiments"
    let OTHER = "Other"
    
    //Other variables
    var type: GroceryType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPopup() //Setup the multiple selection menu
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        //Add constraints for date
        dateControl.minimumDate = Date()
        dateControl.date = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
        dateControl.semanticContentAttribute = .forceRightToLeft
        dateControl.subviews.first?.semanticContentAttribute = .forceRightToLeft
        
        //UI changes
        nameTextField.layer.borderWidth = 1
        nameTextField.layer.cornerRadius = 5
        nameTextField.layer.borderColor = UIColor(named: "buttons")?.cgColor
        
        amountField.layer.borderWidth = 1
        amountField.layer.cornerRadius = 5
        amountField.layer.borderColor = UIColor(named: "buttons")?.cgColor
        
        type = GroceryType(rawValue: 0)
    }
    
    // MARK: - Functions
    
    //Add grocery and save it in the database
    @IBAction func add(_ sender: Any) {
        guard let name = nameTextField.text, let amount = amountField.text, let type = type else {
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
        
        let _ = databaseController?.addGrocery(name: name, type: type, expiry: date, amount: amount)
        navigationController?.popViewController(animated: true)
    }
    
    //Setup the choice popup menu
    //https://www.youtube.com/watch?v=4yZR6AC1PIU
    func setupPopup() {
        let optionClosure = {(action: UIAction) in
            switch action.title {
            case self.DAIRY:
                self.type = GroceryType(rawValue: 0)
                self.dateControl.date = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
            case self.FRUITS_AND_VEGETABLES:
                self.type = GroceryType(rawValue: 1)
                self.dateControl.date = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
            case self.MEAT:
                self.type = GroceryType(rawValue: 2)
                self.dateControl.date = Calendar.current.date(byAdding: .day, value: 10, to: Date())!
            case self.SEAFOOD:
                self.type = GroceryType(rawValue: 3)
                self.dateControl.date = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
            case self.CONDIMENTS:
                self.type = GroceryType(rawValue: 4)
                self.dateControl.date = Calendar.current.date(byAdding: .day, value: 365, to: Date())!
            case self.OTHER:
                self.type = GroceryType(rawValue: 5)
                self.dateControl.date = Date()
            default:
                print("Error")
            }
        }
        
        typeControl.menu = UIMenu(children: [
            UIAction(title: DAIRY, state: .on, handler: optionClosure),
            UIAction(title: FRUITS_AND_VEGETABLES, handler: optionClosure),
            UIAction(title: MEAT, handler: optionClosure),
            UIAction(title: SEAFOOD, handler: optionClosure),
            UIAction(title: CONDIMENTS, handler: optionClosure),
            UIAction(title: OTHER, handler: optionClosure),
        ])
        
        typeControl.showsMenuAsPrimaryAction = true
        typeControl.changesSelectionAsPrimaryAction = true
    }
    
    //Display various messages
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message,
        preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
        handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
}
