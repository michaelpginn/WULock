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
    
    var selectedGymLockerIndex:Int?
    var selectedMailboxIndex:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
            return cell
        }else{
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else{return}
        cell.accessoryType = .checkmark
        
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
