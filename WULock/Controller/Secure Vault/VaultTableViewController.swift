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
    let defaults = UserDefaults.standard
    
    var lockScreenShown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
        NotificationCenter.default.addObserver(self, selector: #selector(loadItems), name: Notification.Name("vault_changed"), object: nil)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !lockScreenShown {
            lockScreenShown = true
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVCNav = storyboard.instantiateViewController(withIdentifier: "loginVCNav")
            self.tabBarController?.present(loginVCNav, animated: false, completion: nil)
        }
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
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let cell = sender as! VaultTableViewCell
            let itemTableViewController = segue.destination as! VaultItemDetailViewController
            guard let index = tableView.indexPath(for: cell) else {
                return
            }
            itemTableViewController.setData(i: items[index.row])
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            //delete the record
            guard let delegate = UIApplication.shared.delegate as? AppDelegate else{return}
            let context = delegate.managedObjectContext
            
            do{
            if let oid = items[indexPath.row].coreDataID, let managedObject = try? context.existingObject(with: oid){
                context.delete(managedObject)
                try context.save()
                items.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                if oid.uriRepresentation() == defaults.url(forKey: CodeSelectionTableViewController.GYM_LOCKER_DEFAULTS_KEY){
                    defaults.set(nil, forKey: CodeSelectionTableViewController.GYM_LOCKER_DEFAULTS_KEY)
                }else if oid.uriRepresentation() == defaults.url(forKey: CodeSelectionTableViewController.MAILBOX_DEFAULTS_KEY){
                    defaults.set(nil, forKey: CodeSelectionTableViewController.MAILBOX_DEFAULTS_KEY)
                }
            }
            }catch let e{
                print(e.localizedDescription)
            }
            
        }
    }
}
