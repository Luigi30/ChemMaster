//
//  SS13Ingredients.swift
//  ChemMaster
//
//  Created by Christopher Rohl on 7/19/17.
//  Copyright © 2017 Christopher Rohl. All rights reserved.
//

import Cocoa

class SS13Ingredient: NSObject {
    let name: String
    let children : [SS13Ingredient] //Ingredients that make up an ingredient.
    
    init(name: String, childIngredients:[SS13Ingredient]) {
        self.name = name
        self.children = childIngredients
    }
}
