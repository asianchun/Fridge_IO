//
//  RecipePopUpViewController.swift
//  Fridge_IO
//
//  Created by Hong Yi on 16/5/2023.
//

import UIKit

class RecipePopUpViewController: UIViewController {

    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    var recipe: RecipeData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popupView.layer.cornerRadius = 10.0
        imageView.layer.cornerRadius = 10.0
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        
        if let imageURL = recipe?.imageURL {
            let url = URL(string: imageURL)!
            
            Task {
                do {
                    let (data, response) = try await URLSession.shared.data(from: url)
                    
                    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                        return
                    }
                    
                    if let image = UIImage(data: data) {
                        imageView.image = image
                    }
                }
            }
            
        }
    }
    
    @IBAction func dismissPopup(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
