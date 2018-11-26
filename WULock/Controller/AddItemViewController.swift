//
//  AddItemViewController.swift
//  WULock
//
//  Created by Michael Ginn on 11/26/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit

class AddItemViewController: UIViewController {
    @IBOutlet var typeViews:[TypeOptionView]!

    private var currentSelectedType:ItemType = .other
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        for tv in typeViews{
            
        }
    }

}
