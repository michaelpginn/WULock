//
//  AddItemViewController.swift
//  WULock
//
//  Created by Michael Ginn on 11/26/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit

class AddItemViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var containerView: UIView!

    @IBOutlet weak var tableView: UITableView!
    
    private var currentSelectedType:ItemType = .other
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //modified from https://stackoverflow.com/questions/37370801/how-to-add-a-container-view-programmatically
        let pickerController = ItemTypePickerController()
        addChild(pickerController)
        pickerController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pickerController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pickerController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            pickerController.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            pickerController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
    }

    @IBAction func save(_ sender: Any) {
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
