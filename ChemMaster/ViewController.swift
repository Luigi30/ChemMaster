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
    @IBOutlet weak var tableView: NSTableView!
    
    var ItemRecipes = [SS13Recipe]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        // Do any additional setup after loading the view.
        let path = Bundle.main.path(forResource:"food", ofType:"yaml")
        let success = importRecipes(recipeFile: path!)
        
        if(!success) {
            dialogOK(title: "Couldn't load Recipes", text: "An error occurred loading the recipe file: \(path!)")
        }
        
        ItemRecipes.sort {
            $0.itemName.localizedCaseInsensitiveCompare($1.itemName) == ComparisonResult.orderedAscending
        }
        
        tableView.reloadData()
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
            
            for recipe in recipes! {
                ItemRecipes.append(SS13Recipe(itemName:recipe["name"].string!))
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
}

extension ViewController: NSTableViewDelegate {
    fileprivate enum CellIdentifiers {
        static let ItemNameCell = "ItemNameCellID"
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var itemName: String = ""
        var cellIdentifier: String = ""
        let item = ItemRecipes[row]
        
        if(tableColumn == tableView.tableColumns[0]) {
            itemName = item.itemName
            cellIdentifier = CellIdentifiers.ItemNameCell
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = itemName
            return cell
        }
        
        return nil
    }
}
