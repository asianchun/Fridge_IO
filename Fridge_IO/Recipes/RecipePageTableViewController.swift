//
//  RecipePageTableViewController.swift
//  Fridge_IO
//
//  Created by Hong Yi on 2/5/2023.
//

import UIKit

class RecipePageTableViewController: UITableViewController, UISearchBarDelegate, FavouritesDelegate {

    //Status enum that is used to show different messages depending on the current status of the page
    enum Status {
        case standard
        case notFound
        case loading
        case noFavourites
    }
    
    //Link to the database
    weak var databaseController: DatabaseProtocol?
    
    //Outlets
    @IBOutlet weak var favouritesButton: UIBarButtonItem!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    //Constants
    let CELL_RECIPE = "recipeCell"
    let ABOUT = "About Fridge.IO"
    let DELETE_ACCOUNT = "Delete Account"
    let LOGOUT = "Log Out"
    
    //Other variables
    var recipes = [RecipeData]()
    var previousRecipes = [RecipeData]()
    var indicator = UIActivityIndicatorView()
    var allGroceries: [Grocery]?    
    var status: Status = .standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSettings() //Setup settings
        
        //Setup search bar
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        //Setup the indicator
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        
        //Constrain the indicator
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        allGroceries = databaseController?.groceries
    }
    
    // MARK: - Search bar functions
    
    //Finish Editing (on enter press)
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            return
        }
        
        //Reset the whole search
        recipes.removeAll()
        status = .loading
        tableView.reloadData()
        favouritesButton.tintColor = .systemBlue
        navigationItem.title = "Recipe Search"
        
        navigationItem.searchController?.dismiss(animated: true)
        indicator.startAnimating()
        
        URLSession.shared.invalidateAndCancel()
        
        Task {
            await requestRecipes(searchText)
        }
    }
    
    //Cancel search -> reset to show all groceries again
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        status = .standard
        indicator.stopAnimating()
        tableView.reloadData()
    }
    
    //MARK: - Functions
    
    //Show favourites
    @IBAction func showFavourites(_ sender: Any) {
        //Hide favourites
        if favouritesButton.tintColor == .systemYellow {
            favouritesButton.tintColor = .systemBlue
            recipes = previousRecipes
            navigationItem.title = "Recipe Search"
            status = .standard
        } else { //Show favourites
            favouritesButton.tintColor = .systemYellow
            previousRecipes = recipes
            navigationItem.title = "Favourite Recipes"
            status = .noFavourites
            
            guard let userID = databaseController?.currentUser?.uid else {
                return
            }
            
            //Retrieve the recipes from the property lists
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentDirectory = paths[0]
            let fileURL = documentDirectory.appendingPathComponent("\(userID)myData.plist")

            do {
                let data = try Data(contentsOf: fileURL)
                let decoder = PropertyListDecoder()
                let favourite = try decoder.decode(Array<RecipeData>.self, from: data)
                
                recipes = favourite
            } catch {
                print(error)
            }
        }
        
        tableView.reloadData()
    }
    
    //Settings
    //https://www.youtube.com/watch?v=4yZR6AC1PIU
    func setupSettings() {
        let optionClosure = {(action: UIAction) in
            switch action.title {
            case self.ABOUT: //Open the about page
                self.performSegue(withIdentifier: "aboutIdentifier", sender: nil)
            case self.LOGOUT: //Logout the user and send back to the login screen
                let alertController = UIAlertController(title: "Log Out", message: "Are you sure you want to logout?", preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                    self.databaseController?.logout()
                    self.performSegue(withIdentifier: "logoutIdentifier", sender: self)
                }))
                
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                
                self.present(alertController, animated: true, completion: nil)
            case self.DELETE_ACCOUNT:
                let alertController = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your account?", preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                    self.databaseController?.deleteUser(completion: {
                        self.databaseController?.logout()
                        self.performSegue(withIdentifier: "logoutIdentifier", sender: self)
                    })
                }))
                
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                
                self.present(alertController, animated: true, completion: nil)
            default:
                print("Error")
            }
        }
        
        settingsButton.menu = UIMenu(children: [
            UIAction(title: LOGOUT, handler: optionClosure),
            UIAction(title: ABOUT, handler: optionClosure),
            UIAction(title: DELETE_ACCOUNT, handler: optionClosure),
        ])
    }
    
    // MARK: - Delegate function
    
    //Updates view if one of the favourite recipes has been unfavourited
    func favouritesChanged(_ newFavourites: [RecipeData]) {
        if favouritesButton.tintColor == .systemYellow {
            recipes = newFavourites
            tableView.reloadData()
        }
    }
    
    // MARK: - Api call
    
    //Call the API
    //https://developer.edamam.com/edamam-recipe-api
    func requestRecipes(_ ingredients: String) async {
        var searchURLComponents = URLComponents()
        searchURLComponents.scheme = "https"
        searchURLComponents.host = "api.edamam.com"
        searchURLComponents.path = "/api/recipes/v2"
        searchURLComponents.queryItems = [
            URLQueryItem(name: "type", value: "public"),
            URLQueryItem(name: "app_id", value: "9333305b"),
            URLQueryItem(name: "app_key", value: "f057783ac2d77497fd46d9f1c286b0f6"),
            URLQueryItem(name: "q", value: ingredients),
            URLQueryItem(name: "random", value: "true"),
        ]
        
        guard let requestURL = searchURLComponents.url else {
            print("Invalid URL")
            return
        }
        
        let urlRequest = URLRequest(url: requestURL)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return
            }
            
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
            }
            
            status = .notFound
            tableView.reloadData()

            do {
                let decoder = JSONDecoder()
                let volumeData = try decoder.decode(VolumeData.self, from: data)
                
                if let results = volumeData.recipes {
                    DispatchQueue.main.async {
                        for result in results {
                            var matching = 0
                            
                            //This checks how many recipe ingredients match with the groceries that the user has in the fridge
                            for grocery in self.allGroceries! {
                                for ingredient in result.ingredients! {
                                    if ingredient.lowercased().contains(grocery.name?.lowercased() ?? ""){
                                        matching += 1
                                    }
                                }
                            }
                            
                            //Only display recipes that have at least 2 matching ingredients
                            if matching >= 2 && !self.recipes.contains(result) {
                                self.recipes.append(result)
                                self.tableView.reloadData()
                            }
                        }
                    }
                    
                    //Keep calling the API until there are atleast 20 recipes shown
                    if recipes.count < 20 {
                        await requestRecipes(ingredients)
                    }
                }
            } catch {
                print(error)
            }
            
        } catch let error {
            print(error)
        }
    }
    
    // MARK: - Table view setup

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if recipes.isEmpty {
            return 1
        } else {
            return recipes.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_RECIPE, for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        
        if recipes.isEmpty {
            cell.selectionStyle = .none
            tableView.allowsSelection = false
            
            //Different message based on the status of the page
            switch status {
            case .standard:
                content.text = "Search to find some new recipes!"
            case .notFound:
                content.text = "No recipes found based on your fridge!"
            case .loading:
                content.text = "Looking for recipes..."
            case .noFavourites:
                content.text = "No favourite recipes saved."
            }
        } else {
            cell.selectionStyle = .default
            tableView.allowsSelection = true
            
            let recipe = recipes[indexPath.row]
            content.text = recipe.name
            
            if let diatary = recipe.diateries, diatary.isEmpty {
                content.secondaryText = "Calories: \(recipe.calories ?? 0) | This recipe contains no diateries"
            } else {
                content.secondaryText = "Calories: \(recipe.calories ?? 0) | Contains: \(recipe.diateries ?? "None")"
            }
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor(named: "selected")
            cell.selectedBackgroundView = backgroundView
        }
        
        cell.contentConfiguration = content
        return cell
    }
    
    //Open the specific recipe
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "recipeIdentifier", sender: indexPath)
    }
    
    //MARK: - Long Tap Gesture
    
    //Handle the gesture and show the popup based on the recipe that handled the gesture
    //https://stackoverflow.com/questions/37770240/how-to-make-tableviewcell-handle-both-tap-and-longpress
    @IBAction func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            let touchPoint = recognizer.location(in: tableView)
            
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                if !recipes.isEmpty {
                    performSegue(withIdentifier: "popupIdentifier", sender: indexPath)
                }
            }
        }
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.backButtonTitle = "Back"
        
        if segue.identifier == "recipeIdentifier" {
            let sender = sender as! IndexPath
            
            let destination = segue.destination as! RecipeViewController
            destination.recipe = recipes[sender.row]
            
            if favouritesButton.tintColor == .systemYellow {
                destination.favouritesButton.tintColor = .systemYellow
            }
            
            destination.favouritesDelegate = self
        } else if segue.identifier == "popupIdentifier" {
            let sender = sender as! IndexPath
            
            let destination = segue.destination as! RecipePopUpViewController
            destination.recipe = recipes[sender.row]
        }
    }
}
