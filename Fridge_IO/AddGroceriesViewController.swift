//
//  AddGroceriesViewController.swift
//  Fridge_IO
//
//  Created by Hong Yi on 2/5/2023.
//

import UIKit

class AddGroceriesViewController: UIViewController {

    weak var databaseController: DatabaseProtocol?
    
    @IBOutlet weak var dateControl: UIDatePicker!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var amountField: UITextField!
    @IBOutlet weak var typeSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        // Do any additional setup after loading the view.
    }
    
    @IBAction func add(_ sender: Any) {
        guard let name = nameTextField.text, let amount = amountField.text, let type = GroceryType(rawValue: Int(typeSegmentedControl.selectedSegmentIndex)) else {
            return
        }
        
        let date = dateControl.date
        let currentDate = Date()
        
        let difference = Calendar.current.dateComponents([Calendar.Component.day], from: date, to: currentDate)
        
        
        if name.isEmpty || amount.isEmpty || difference.day! > 0 {
            var errorMsg = "Please ensure all fields are filled : \n"
            
            if name.isEmpty {
                errorMsg += "- Must provide a name \n"
            }
            if amount.isEmpty {
                errorMsg += "- Must provide an amount \n"
            }
            if difference.day! > 0 {
                errorMsg += "- Must be a date in the future"
            }
            
            displayMessage(title: "Not all fields filled", message: errorMsg)
            return
        }
        
        let _ = databaseController?.addGrocery(name: name, type: type, expiry: date, amount: amount)
        navigationController?.popViewController(animated: true)
    }
    
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message,
        preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
        handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
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
