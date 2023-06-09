//
//  RecipeViewController.swift
//  Fridge_IO
//
//  Created by Hong Yi on 10/5/2023.
//

import UIKit

class RecipeViewController: UIViewController {
    
    //Link to the database and delegate
    weak var favouritesDelegate: FavouritesDelegate?
    weak var databaseController: DatabaseProtocol?
    
    //Outlets
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var urlText: UITextView!
    @IBOutlet weak var sourceText: UITextView!
    @IBOutlet weak var mealTypeText: UITextView!
    @IBOutlet weak var containsText: UITextView!
    @IBOutlet weak var caloriesText: UITextView!
    @IBOutlet weak var ingredientLinesText: UITextView!
    @IBOutlet weak var ingredientLinesTextHC: NSLayoutConstraint!
    @IBOutlet weak var contentViewHC: NSLayoutConstraint!
    @IBOutlet weak var favouritesButton: UIBarButtonItem!
    
    //Other variables
    var recipe: RecipeData?
    var indicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup the indicator
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        imageContainer.addSubview(indicator)
        
        //Constrain the indicator
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: imageContainer.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: imageContainer.centerYAnchor)
        ])
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController

        //Populate the view with data
        navigationItem.title = recipe?.name ?? ""
        imageView.layer.cornerRadius = 8.0
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor(named: "imageBorder")?.cgColor
        
        sourceText.text = recipe?.source
        caloriesText.text = "\(recipe?.calories ?? 0) calories"
        urlText.text = recipe?.url ?? "No url"
        mealTypeText.text = recipe?.mealType ?? "Can enjoy it anytime!"
        
        let ingredients = recipe?.ingredientLines?.joined(separator: "  >>  ")
        ingredientLinesText.text = ingredients
        contentViewHC.constant = contentViewHC.constant + ingredientLinesText.contentSize.height
        ingredientLinesTextHC.constant = ingredientLinesText.contentSize.height

        if let diatary = recipe?.diateries, !diatary.isEmpty {
            containsText.text = diatary
        } else {
            containsText.text = "This recipe contains no diataries"
        }
        
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
    
    // MARK: - Functions
    
    //Add recipe to favourites
    @IBAction func addToFavourites(_ sender: Any) {
        var favourites = [RecipeData]()
        
        guard let userID = databaseController?.currentUser?.uid else {
            return
        }

        //Take all the recipes currently in the property list
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        let fileURL = documentDirectory.appendingPathComponent("\(userID)myData.plist")
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = PropertyListDecoder()
            favourites = try decoder.decode(Array<RecipeData>.self, from: data)
        } catch {
            print(error)
        }
        
        //Unfavourite
        if favouritesButton.tintColor == .systemYellow {
            favouritesButton.tintColor = .systemBlue
            
            //Remove the recipe from the list of favourite recipes
            for (index, favourite) in favourites.enumerated() {
                if favourite.name == recipe?.name {
                    favourites.remove(at: index)
                    break
                }
            }
            
            //Tell the delegate that the favourite has been removed
            favouritesDelegate?.favouritesChanged(favourites)
            
        } else { //Favourite
            favouritesButton.tintColor = .systemYellow
            
            //Add the recipe to the list of favourite recipes
            favourites.append(recipe!)
        }
        
        //Put the new list of recipes into the property list
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml

        do {
            let data = try encoder.encode(favourites)
            try data.write(to: fileURL)
        } catch {
            print(error)
        }
    }
    
    //Ask the user for confirmation
    //Adding the recipe to the grocery lists
    @IBAction func addToGroceryList(_ sender: Any) {
        displayMessage(title: "Add to Grocery List", message: "Are you sure you want to add '\(recipe?.name ?? "")' to your grocery list?")
    }
    
    //Displays a message with options
    func displayMessage(title: String, message: String) {
        //Create a success message
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let messageController = UIAlertController(title: "Success", message: "Recipe successfully added to your grocery list", preferredStyle: .alert)
        
        messageController.addAction(UIAlertAction(title: "Dismiss", style: .default,
        handler: nil))
        
        //If they want to add, we add the new grocery list with the recipe's ingredients
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            let _ = self.databaseController?.addGroceryList(name: (self.recipe?.name!)!, listItems: (self.recipe?.ingredientLines!)!)
            
            //Show the success message
            self.present(messageController, animated: true, completion: nil)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alertController, animated: true, completion: nil)
    }
}
