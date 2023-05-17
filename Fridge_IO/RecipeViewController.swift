//
//  RecipeViewController.swift
//  Fridge_IO
//
//  Created by Hong Yi on 10/5/2023.
//

import UIKit

class RecipeViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var urlText: UITextView!
    @IBOutlet weak var sourceText: UITextView!
    @IBOutlet weak var mealTypeText: UITextView!
    @IBOutlet weak var containsText: UITextView!
    @IBOutlet weak var caloriesText: UITextView!
    @IBOutlet weak var ingredientLinesText: UITextView!
    @IBOutlet weak var favouritesButton: UIBarButtonItem!
    
    var recipe: RecipeData?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = recipe?.name ?? ""
        imageView.layer.cornerRadius = 8.0
        
        sourceText.text = recipe?.source
        caloriesText.text = "\(recipe?.calories ?? 0) calories"
        urlText.text = recipe?.url ?? "No url"
        mealTypeText.text = recipe?.mealType ?? "Can enjoy it anytime!"
        
        let ingredients = recipe?.ingredientLines?.joined(separator: "\n")
        ingredientLinesText.text = ingredients

        if let diatary = recipe?.diateries, !diatary.isEmpty {
            containsText.text = diatary
        } else {
            containsText.text = "This recipe contains no diataries"
        }
        
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
    
    @IBAction func addToFavourites(_ sender: Any) {
        //Unfavourite
        if favouritesButton.tintColor == .systemYellow {
            favouritesButton.tintColor = .systemBlue
        } else {
            favouritesButton.tintColor = .systemYellow
            
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentDirectory = paths[0]
            let fileURL = documentDirectory.appendingPathComponent("/myData.plist")
            let encoder = PropertyListEncoder()
            encoder.outputFormat = .xml

            do {
                let data = try encoder.encode(recipe)
                try data.write(to: fileURL)
            } catch {
                print(error)
            }
        }
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
