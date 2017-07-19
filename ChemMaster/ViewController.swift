//
//  ViewController.swift
//  ChemMaster
//
//  Created by Christopher Rohl on 7/16/17.
//  Copyright © 2017 Christopher Rohl. All rights reserved.
//

import Cocoa
import Yaml

class ViewController: NSViewController {
    @IBOutlet weak var recipesTableView: NSTableView!
    @IBOutlet weak var ingredientsView: NSOutlineView!
    
    @IBOutlet weak var recipeCount: NSTextField!
    @IBOutlet weak var notesField: NSTextField!
    @IBOutlet weak var sourcesField: NSTextField!
    
    var ItemRecipes = [Recipe]()
    var Ingredients = [SS13Ingredient]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        recipesTableView.delegate = self
        recipesTableView.dataSource = self
        
        ingredientsView.delegate = self
        ingredientsView.dataSource = self

        // Do any additional setup after loading the view.
        let path = Bundle.main.path(forResource:"food", ofType:"yaml")
        let success = importRecipes(recipeFile: path!)
        
        if(!success) {
            dialogOK(title: "Couldn't load Recipes", text: "An error occurred loading the recipe file: \(path!)")
        }
        
        ItemRecipes.sort {
            $0.itemName.localizedCaseInsensitiveCompare($1.itemName) == ComparisonResult.orderedAscending
        }
        
        recipesTableView.reloadData()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func importRecipes(recipeFile: String) -> Bool {
        do {
            print("Loading recipe file: \(recipeFile)")
            let text = try String.init(contentsOfFile: recipeFile)
            let recipeYaml = try Yaml.load(text)
            let recipes = recipeYaml["recipes"].array;
            print("Loaded \(recipes!.count) recipes from \(recipeFile).")
            recipeCount.stringValue = "\(recipes!.count) recipes loaded"
            
            for recipe in recipes! {
                var recipeTags = Array<ItemTag>()
                var sources = Array<String>()
                var ingredients = Array<SS13Ingredient>()
                
                recipe["tags"].array?.forEach {
                    let tag = $0
                    if let tagString = tag.string {
                        recipeTags.append(getTagForString(tagString: tagString))
                    }
                }
                
                recipe["sources"].array?.forEach {
                    if let sourceString = $0.string {
                        sources.append(sourceString)
                    }
                }
                
                recipe["ingredients"].array?.forEach {
                    if let ingredientString = $0.string {
                        let ingredient = SS13Ingredient(name: ingredientString, childIngredients: Array<SS13Ingredient>())
                        ingredients.append(ingredient)
                    }
                }
                
                let notes = recipe["info"]["notes"].string
                
                ItemRecipes.append(Recipe(itemName:recipe["name"].string!, notes:notes, tags: recipeTags, sources: sources, ingredients: ingredients))
            }
            
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    func dialogOK(title: String, text: String) -> Void {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
}

//Table view stuff
extension ViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return ItemRecipes.count
    }
    
    func getItem(atIndex: Int) -> Recipe {
        return ItemRecipes[atIndex]
    }
}

extension ViewController: NSTableViewDelegate {
    fileprivate enum CellIdentifiers {
        static let ItemNameCell = "ItemNameCellID"
        static let TagCell      = "TagCellID"
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let myTable = notification.object as? NSTableView {
            // we create an [Int] array from the index set
            let selected = myTable.selectedRowIndexes.map { Int($0) }
            let recipe = ItemRecipes[selected[0]]
            
            /* Update the text fields with the new item info. */
            let notesString = recipe.notes
            if(notesString == nil) {
                notesField.stringValue = "No notes found for this recipe."
            } else {
                notesField.stringValue = notesString!
            }
            
            var sourcesString = ""
            for source in recipe.sources {
                sourcesString.append(source)
                sourcesString.append("; ")
            }
            if(sourcesString != "") {
                sourcesString.removeLast()
                sourcesString.removeLast()
                sourcesField.stringValue = sourcesString
            } else {
                sourcesField.stringValue = "N/A"
            }
            
            Ingredients = recipe.ingredients
            ingredientsView.reloadData()
        }
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var cellText: String = ""
        var cellIdentifier: String = ""
        let item = ItemRecipes[row]
        
        if(tableColumn == tableView.tableColumns[0]) {
            cellText = item.itemName
            cellIdentifier = CellIdentifiers.ItemNameCell
        }
        else if(tableColumn == tableView.tableColumns[1]) {
            for tag in item.tags {
                cellText += tag.rawValue + " "
            }
            cellIdentifier = CellIdentifiers.TagCell
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = cellText
            return cell
        }
        
        return nil
    }
}

//Ingredients outline view stuff
extension ViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let ingredient = item as? SS13Ingredient {
            return ingredient.children.count
        }
        return Ingredients.count
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let ingredient = item as? SS13Ingredient {
            return ingredient.children.count > 0
        }
        
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let ingredient = item as? SS13Ingredient {
            return ingredient.children[index]
        }
        
        return Ingredients[index]
    }
}

extension ViewController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var view: NSTableCellView?
        
        if let ingredient = item as? SS13Ingredient {
            view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "IngredientCellID"), owner: self) as? NSTableCellView
            if let textField = view?.textField {
                textField.stringValue = ingredient.name
            }
        }
        
        return view
    }
    
}
