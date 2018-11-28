//
//  VaultTableViewController.swift
//  WULock
//
//  Created by Michael Ginn on 11/26/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit
import CoreData


class VaultTableViewController: UITableViewController {
    var items:[VaultItem] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadItems()
        NotificationCenter.default.addObserver(self, selector: #selector(loadItems), name: Notification.Name("vault_changed"), object: nil)
        
        
    }

    
    
    
    @objc private func loadItems(){
        items = []
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let context = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        
        do{
            let results = try context.fetch(fetchRequest)
            for result in results as? [NSManagedObject] ?? []{
                items.append(VaultItem(managedObject: result))
            }
            tableView.reloadData()
        }catch let e{
            print(e.localizedDescription)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let thisItem = items[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as? VaultTableViewCell{
            cell.label.text = thisItem.description
            cell.iconImageView.image = thisItem.type.getImage()
            return cell
        }else{
            return UITableViewCell()
        }
    }
 


}
