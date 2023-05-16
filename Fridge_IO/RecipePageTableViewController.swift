//
//  RecipePageTableViewController.swift
//  Fridge_IO
//
//  Created by Hong Yi on 2/5/2023.
//

import UIKit

class RecipePageTableViewController: UITableViewController, UISearchBarDelegate {
    
    enum Status {
        case standard
        case notFound
        case loading
    }
    
    weak var databaseController: DatabaseProtocol?
    
    let CELL_RECIPE = "recipeCell"
    
    var recipes = [RecipeData]()
    var indicator = UIActivityIndicatorView()
    var allGroceries: [Grocery]?    
    var status: Status = .standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        allGroceries = databaseController?.groceries
    }
    
    //Search bar function
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            return
        }
        
        recipes.removeAll()
        status = .loading
        tableView.reloadData()
        
        navigationItem.searchController?.dismiss(animated: true)
        indicator.startAnimating()
        
        URLSession.shared.invalidateAndCancel()
        
        Task {
            await requestRecipes(searchText)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        status = .standard
        tableView.reloadData()
    }
    
    //Api call
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
                            
                            for grocery in self.allGroceries! {
                                for ingredient in result.ingredients! {
                                    if ingredient.lowercased().contains(grocery.name?.lowercased() ?? ""){
                                        matching += 1
                                    }
                                }
                            }
                            
                            if matching >= 2 && !self.recipes.contains(result) {
                                self.recipes.append(result)
                                self.tableView.reloadData()
                            }
                            //Another way to reload data
                            //self.tableView.insertRows(at: [IndexPath(row: self.newBooks.count - 1, section: 0)], with: .fade)
                        }
                    }
                    
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
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
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
            switch status {
            case .standard:
                content.text = "Search to find some new recipes!"
            case .notFound:
                content.text = "No recipes found based on your fridge!"
            case .loading:
                content.text = "Looking for recipes..."
            }
        } else {
            let recipe = recipes[indexPath.row]
            
            content.text = recipe.name
            
            if let diatary = recipe.diateries, diatary.isEmpty {
                content.secondaryText = "Calories: \(recipe.calories ?? 0) | This recipe contains no diateries"
            } else {
                content.secondaryText = "Calories: \(recipe.calories ?? 0) | Contains: \(recipe.diateries ?? "None")"
            }

        }
        
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "recipeIdentifier", sender: indexPath)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "recipeIdentifier" {
            let sender = sender as! IndexPath
            let destination = segue.destination as! RecipeViewController
            
            destination.recipe = recipes[sender.row]
        }
    }
}
