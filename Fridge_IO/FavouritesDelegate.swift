//
//  FavouritesDelegate.swift
//  Fridge_IO
//
//  Created by Hong Yi on 17/5/2023.
//

import Foundation

//Protocol that sends the new favourites, if they have changed
protocol FavouritesDelegate: AnyObject {
    func favouritesChanged(_ newFavourites: [RecipeData])
}

