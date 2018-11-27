//
//  AddItemViewController.swift
//  WULock
//
//  Created by Michael Ginn on 11/26/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit

class AddItemViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ItemTypePickerControllerDelegate {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    private var currentSelectedType:ItemType = .other
    private var defaultFields:[ItemField] = []
    private var userFields:[ItemField] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //modified from https://stackoverflow.com/questions/37370801/how-to-add-a-container-view-programmatically
        let pickerController = ItemTypePickerController()
        pickerController.delegate = self
        addChild(pickerController)
        pickerController.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(pickerController.view)
        NSLayoutConstraint.activate([
            pickerController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pickerController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            pickerController.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            pickerController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
    }

    // MARK: ItemTypePickerControllerDelegate method
    func optionSelected(title: String, reqFields: [String]) {
        //reload the table view with the correct fields
        currentSelectedType = ItemType(rawValue: title) ?? .other
        defaultFields = []
        for field in reqFields{
            defaultFields.append((field, nil))
        }
        tableView.reloadSections(IndexSet(integer: 0), with: .fade)
    }
    
    // MARK: Interface methods
    @IBAction func save(_ sender: Any) {
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 //one for default fields, one for user entered ones
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return defaultFields.count
        }else if section == 1{
            return userFields.count + 1
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier:String = indexPath.section == 0 ? "setFieldCell" : "customFieldCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? FieldTableViewCell else{return UITableViewCell()}
        
        if indexPath.section == 0{
            cell.setDescription(defaultFields[indexPath.row].0)
        }
        
        return cell
    }
}
