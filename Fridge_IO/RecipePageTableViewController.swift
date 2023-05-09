//
//  RecipePageTableViewController.swift
//  Fridge_IO
//
//  Created by Hong Yi on 2/5/2023.
//

import UIKit

class RecipePageTableViewController: UITableViewController, UISearchBarDelegate {
    
    let CELL_RECIPE = "recipeCell"
    
    var recipes: [String] = [] //Change this with RecipeData
    var indicator = UIActivityIndicatorView()
    
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
    }
    
    //Search bar function
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        recipes.removeAll()
        tableView.reloadData()
        
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            return
        }
        
        navigationItem.searchController?.dismiss(animated: true)
        indicator.startAnimating()
        
        URLSession.shared.invalidateAndCancel()
        
        Task {
            await requestRecipes(searchText)
        }
    }
    
    func requestRecipes(_ ingredients: String) async {
        var searchURLComponents = URLComponents()
        searchURLComponents.scheme = "https"
        searchURLComponents.host = "api.edamam.com"
        searchURLComponents.path = "api/recipes/v2"
        searchURLComponents.queryItems = [
            URLQueryItem(name: "type", value: "public"),
            URLQueryItem(name: "app_id", value: "9333305b"),
            URLQueryItem(name: "app_key", value: "f057783ac2d77497fd46d9f1c286b0f6"),
            URLQueryItem(name: "q", value: ingredients)
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
            
            do {
//                let decoder = JSONDecoder()
//                let volumeData = try decoder.decode(VolumeData.self, from: data)
//
//                if let books = volumeData.books {
//                    DispatchQueue.main.async {
//                        for book in books {
//                            self.newBooks.append(book)
//                            self.tableView.insertRows(at: [IndexPath(row: self.newBooks.count - 1, section: 0)], with: .fade)
//                        }
//
//                    }
//
//                    if books.count == MAX_ITEMS_PER_REQUEST, currentRequestIndex + 1 < MAX_REQUESTS {
//                        currentRequestIndex += 1
//                        await requestBooksNamed(bookName)
//                    }
//
//                }
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
            content.text = "Search to find some new recipes!"
            content.secondaryText = ""
        } else {
            let recipe = recipes[indexPath.row]
            
            content.text = "Test"
            content.secondaryText = "Test"
        }
        
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Transition to the recipe specific page
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
