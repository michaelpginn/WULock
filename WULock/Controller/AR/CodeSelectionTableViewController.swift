//
//  CodeSelectionTableViewController.swift
//  WULock
//
//  Created by Michael Ginn on 12/1/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit
import CoreData

class CodeSelectionTableViewController: UITableViewController {
    var gymLockerCodes:[VaultItem] = []
    var mailboxCodes:[VaultItem] = []
    
    var selectedGymLockerIndex:IndexPath?
    var selectedMailboxIndex:IndexPath?
    
    var defaults = UserDefaults.standard
    let GYM_LOCKER_DEFAULTS_KEY = "current_gym_locker_item"
    let MAILBOX_DEFAULTS_KEY = "current_mailbox_item"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFromCoreData()
    }
    
    private func loadFromCoreData(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return}
        let context = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        let predicate = NSPredicate(format: "type==%@ OR type==%@", ItemType.gymLocker.rawValue, ItemType.mailbox.rawValue)
        fetchRequest.predicate = predicate
        do{
            let results = try context.fetch(fetchRequest)
            
            for result in results as? [NSManagedObject] ?? []{
                let vaultItem = VaultItem(managedObject: result)
                
                if vaultItem.canParse(){
                    if vaultItem.type == .gymLocker{
                        self.gymLockerCodes.append(vaultItem)
                    }else if vaultItem.type == .mailbox{
                        self.mailboxCodes.append(vaultItem)
                    }
                }
            }
            tableView.reloadData()
        }catch let e{
            print(e.localizedDescription)
        }
    }
    
    
    @IBAction func close(sender: Any){
        self.dismiss(animated: true, completion:nil)
        //self.navigationController?.dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return gymLockerCodes.count
        }else if section == 1{
            return mailboxCodes.count
        }else{
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "codeCell") else{return UITableViewCell()}
        
        if indexPath.section == 0{
            let code = gymLockerCodes[indexPath.row]
            cell.textLabel?.text = "Locker number: " + (code.get(desc: "Locker number") ?? "")
            if let nums = code.parse(){
                var codeString = ""
                for num in nums{
                    codeString.append(String(num))
                }
                cell.detailTextLabel?.text = "Code: " + codeString
            }
            
            cell.accessoryType = .none
            
            if code.coreDataID?.uriRepresentation() == defaults.url(forKey: GYM_LOCKER_DEFAULTS_KEY){
                cell.accessoryType = .checkmark
                selectedGymLockerIndex = indexPath
            }
            
            
            return cell
        }else if indexPath.section == 1{
            let code = mailboxCodes[indexPath.row]
            cell.textLabel?.text = "Mailbox number: " + (code.get(desc: "Mailbox number") ?? "")
            if let nums = code.parse(){
                var codeString = ""
                codeString.append("\(nums[0])")
                codeString.append("-\(nums[1])")
                codeString.append("-\(nums[2])")
                cell.detailTextLabel?.text = "Code: " + codeString
            }
            
            cell.accessoryType = .none
            if code.coreDataID?.uriRepresentation() == defaults.url(forKey: MAILBOX_DEFAULTS_KEY){
                cell.accessoryType = .checkmark
                selectedGymLockerIndex = indexPath
            }
            return cell
        }else{
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else{return}
        tableView.deselectRow(at: indexPath, animated: true)
        
        cell.accessoryType = .checkmark
        
        var previousCell:UITableViewCell? = nil
        
        var indexToCheck:IndexPath?
        let defaultsKey:String
        let itemsArray:[VaultItem]
        
        if indexPath.section == 0{
            indexToCheck = selectedGymLockerIndex
            defaultsKey = GYM_LOCKER_DEFAULTS_KEY
            itemsArray = gymLockerCodes
        }else{
            indexToCheck = selectedMailboxIndex
            defaultsKey = MAILBOX_DEFAULTS_KEY
            itemsArray = mailboxCodes
        }
        
        if indexPath != indexToCheck{
            let item = itemsArray[indexPath.row]
            VaultItem.setToDefaults(key: defaultsKey, item: item)
            if let index = indexToCheck{
                previousCell = tableView.cellForRow(at: index)
            }
            indexToCheck = indexPath
        }else{
            
        }
        
        if indexPath.section == 0{
            //Gym lockers
            if indexPath != selectedGymLockerIndex{
                //Item is not already selected
                let item = gymLockerCodes[indexPath.row]
                VaultItem.setToDefaults(key: GYM_LOCKER_DEFAULTS_KEY, item: item)
                if let index = selectedGymLockerIndex{
                    previousCell = tableView.cellForRow(at: index)
                }
                selectedGymLockerIndex = indexPath
            }else{
                //Item is already selected
                VaultItem.clearDefaultsForKey(key: GYM_LOCKER_DEFAULTS_KEY)
                cell.accessoryType = .none
                selectedGymLockerIndex = nil
            }
        }else if indexPath.section == 1{
            //Mailboxes
            if indexPath != selectedMailboxIndex{
                let item = gymLockerCodes[indexPath.row]
                VaultItem.setToDefaults(key: MAILBOX_DEFAULTS_KEY, item: item)
                if let index = selectedMailboxIndex{
                    previousCell = tableView.cellForRow(at: index)
                }
                selectedMailboxIndex = indexPath
            }else{
                VaultItem.clearDefaultsForKey(key: MAILBOX_DEFAULTS_KEY)
                cell.accessoryType = .none
                selectedMailboxIndex = nil
            }
        }
        
        previousCell?.accessoryType = .none
        
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section{
        case 0:
            return "Locker combos"
        case 1:
            return "Mailbox combos"
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }

}
