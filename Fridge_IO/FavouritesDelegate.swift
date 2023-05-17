//
//  FavouritesDelegate.swift
//  Fridge_IO
//
//  Created by Hong Yi on 17/5/2023.
//

import Foundation

protocol FavouritesDelegate: AnyObject {
    func favouritesChanged(_ newFavourites: [RecipeData])
}

