//
//  RecipeViewController.swift
//  Fridge_IO
//
//  Created by Hong Yi on 10/5/2023.
//

import UIKit

class RecipeViewController: UIViewController {
    
    var recipe: RecipeData?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = recipe?.name ?? ""
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
