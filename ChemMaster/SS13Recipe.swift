//
//  SS13Recipe.swift
//  ChemMaster
//
//  Created by Christopher Rohl on 7/17/17.
//  Copyright © 2017 Christopher Rohl. All rights reserved.
//

import Cocoa

enum ItemTag: String {
    case kitchen    = "kitchen"
    case produce    = "produce"
    case food       = "food"
    case condiment  = "condiment"
    case dynamic    = "dynamic"
    case stun       = "stun"
    case disease    = "disease"
    case container  = "container"
    case clothes    = "clothes"
    case equip      = "equip"
    case tool       = "tool"
    case weapon     = "weapon"
    case drink      = "drink"
    case addictive  = "addictive"
    case errorTag   = "errorTag"
}

func getTagForString(tagString: String) -> ItemTag {
    if(tagString == "kitchen") {
        return .kitchen
    } else if(tagString == "produce") {
        return .produce
    } else if(tagString == "food") {
        return .food
    } else if(tagString == "condiment") {
        return .condiment
    } else if(tagString == "dynamic") {
        return .dynamic
    } else if(tagString == "stun") {
        return .stun
    } else if(tagString == "disease") {
        return .disease
    } else if(tagString == "container") {
        return .container
    } else if(tagString == "equip") {
        return .equip
    } else if(tagString == "clothes") {
        return .clothes
    } else if(tagString == "tool") {
        return .tool
    } else if(tagString == "weapon") {
        return .weapon
    } else if(tagString == "addictive") {
        return .addictive
    } else if(tagString == "drink") {
        return .drink
    } else {
        print("unkown tag encountered: \(tagString)")
        return .errorTag
    }
}

class Recipe: NSObject {
    var itemName: String
    var tags: Array<ItemTag>
    
    init(itemName: String, tags: Array<ItemTag>) {
        self.itemName = itemName
        self.tags = tags
    }
    
}
