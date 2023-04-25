//
//  ViewController.swift
//  Fridge_IO
//
//  Created by Hong Yi on 21/4/2023.
//

import UIKit

class LoginScreenViewController: UIViewController, DatabaseListener {
    
    //Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    //Other variables
    var listenerType = ListenerType.auth
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    //Setup & Remove listeners
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    //Listener functions
    func onAuthChange(success: Bool, message: String?) {
        DispatchQueue.main.async {
            if success {
                self.performSegue(withIdentifier: "loginIdentifier", sender: self)
            } else {
                self.displayMessage(title: "Error", message: message!)
            }
        }
    }
    
    //Login
    @IBAction func loginBtn(_ sender: Any) {
        let (emailIsValid, email, password) = validateFields()
        
        if !emailIsValid {
            return
        }
        
        databaseController?.login(email: email, password: password)
    }
    
    //Reset password
    @IBAction func resetPassword(_ sender: Any) {
        let alertController = UIAlertController(title: "Reset password", message: "Enter your email", preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: { textfield in
            textfield.placeholder = "Enter an email..."
        })
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            guard let email = alertController.textFields![0].text, !email.isEmpty else {
                self.displayMessage(title: "Error", message: "Enter an email")
                return
            }
            
            self.databaseController?.resetPassword(email: email)
            self.displayMessage(title: "Success", message: "A reset link has been sent to your email")
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //Validation of the input fields
    func validateFields() -> (Bool, String, String) {
        guard let email = emailTextField.text, !email.isEmpty else {
            displayMessage(title: "Error", message: "Enter an email address!")
            return (false, "", "")
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            displayMessage(title: "Error", message: "Enter a password!")
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
}

