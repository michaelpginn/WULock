//
//  VaultItemDetailViewController.swift
//  WULock
//
//  Created by Michael Ginn on 11/28/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit
import CoreData

class VaultItemDetailViewController: UITableViewController {
    var item: VaultItem!
    var descriptions: [ItemField] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    func setData(i: VaultItem) {
        self.item = i
        self.descriptions = i.getWithoutDescription()
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.descriptions.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let thisItem = descriptions[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "vaultDetailCell", for: indexPath) as? VaultItemDetailCell{
            cell.label.text = thisItem.fieldDescription + ": " + thisItem.fieldValue
            return cell
        }else{
            return UITableViewCell()
        }
    }
    
    
    
}
