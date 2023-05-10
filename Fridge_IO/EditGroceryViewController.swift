//
//  EditGroceryViewController.swift
//  Fridge_IO
//
//  Created by Hong Yi on 10/5/2023.
//

import UIKit

class EditGroceryViewController: UIViewController {
    
    var grocery: Grocery?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = grocery?.name ?? ""
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
