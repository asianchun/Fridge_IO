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
    var indicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popupView.layer.cornerRadius = 10.0
        imageView.layer.cornerRadius = 10.0
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        if let imageURL = recipe?.imageURL {
            indicator.startAnimating()
            
            let url = URL(string: imageURL)!
            Task {
                do {
                    let (data, response) = try await URLSession.shared.data(from: url)
                    
                    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.indicator.stopAnimating()
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
