//
//  AddItemViewController.swift
//  WULock
//
//  Created by Michael Ginn on 11/26/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit

class AddItemViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet var typeViews:[TypeOptionView]!

    @IBOutlet weak var tableView: UITableView!
    
    private var currentSelectedType:ItemType = .other
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        for tv in typeViews{
            
        }
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
