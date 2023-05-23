//
//  SignUpScreenViewController.swift
//  Fridge_IO
//
//  Created by Hong Yi on 21/4/2023.
//

import UIKit

class SignUpScreenViewController: UIViewController, DatabaseListener {

    //Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var confirmEmailTextField: UITextField!
   
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    //Other variables
    var listenerType = ListenerType.auth
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    func onAuthChange(success: Bool, message: String?) {
        DispatchQueue.main.async {
            if success {
                self.performSegue(withIdentifier: "signupIdentifier", sender: self)
            } else {
                self.displayMessage(title: "Error", message: message!)
            }
        }
    }
    
    //Sign Up
    @IBAction func signup(_ sender: Any) {
        let (emailIsValid, email, password) = validateFields()
        
        if !emailIsValid {
            return
        }
        
        databaseController?.signup(email: email, password: password)
    }
    
    //Return the user to the login screen
    @IBAction func cancelBtn(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    //Validation of the input fields
    func validateFields() -> (Bool, String, String) {
        guard let email = emailTextField.text, !email.isEmpty else {
            displayMessage(title: "Error", message: "Enter an email address!")
            return (false, "", "")
        }
        
        guard let confirmEmail = confirmEmailTextField.text, confirmEmail == email else {
            displayMessage(title: "Error", message: "Emails do not match!")
            return (false, "", "")
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            displayMessage(title: "Error", message: "Enter a password!")
            return (false, "", "")
        }
        
        guard let confirmPassword = confirmPasswordTextField.text, confirmPassword == password else {
            displayMessage(title: "Error", message: "Passwords do not match!")
            return (false, "", "")
        }
        
        let emailValidationRegex = "^[\\p{L}0-9!#$%&'*+\\/=?^_`{|}~-][\\p{L}0-9.!#$%&'*+\\/=?^_`{|}~-]{0,63}@[\\p{L}0-9-]+(?:\\.[\\p{L}0-9-]{2,7})*$"
        
        let emailValidationPredicate = NSPredicate(format: "SELF MATCHES %@", emailValidationRegex)
        
        if emailValidationPredicate.evaluate(with: email) {
            return (true, email, password)
        } else {
            displayMessage(title: "Error", message: "Enter a valid email address!")
            return (false, "", "")
        }
    }
    
    //Display message function
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message,
        preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
        handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //Useless
    func onGroceriesChange(change: DatabaseChange, groceries: [Grocery]) {
        //Do nothing
    }
    
    func onGroceryListsChange(change: DatabaseChange, groceryLists: [GroceryList]) {
        //Do nothing
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
