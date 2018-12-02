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
        
        self.navigationItem.largeTitleDisplayMode = .never
        
        let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 65, height: 65))
        imgView.contentMode = .scaleAspectFit
        let img = item.type.getImage()
        imgView.image = img
        self.navigationItem.titleView = imgView
    
    }
    func setData(i: VaultItem) {
        self.item = i
        self.descriptions = i.getAllFields()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "vaultDetailCell", for: indexPath)
        cell.textLabel?.text = thisItem.fieldDescription
        cell.detailTextLabel?.text = thisItem.fieldValue + " "
        return cell
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    
    
}
