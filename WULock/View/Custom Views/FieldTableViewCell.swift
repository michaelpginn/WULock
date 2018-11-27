//
//  FieldTableViewCell.swift
//  WULock
//
//  Created by Michael Ginn on 11/26/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit

class FieldTableViewCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var descTextField:UITextField?
    @IBOutlet weak var descLabel: UILabel?
    @IBOutlet weak var valueTextField:UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        valueTextField.delegate = self
    }

    public func setDescription(_ desc:String){
        if descTextField != nil{
            descTextField?.text = desc
        }else{
            valueTextField.placeholder = desc
        }
    }

    @IBAction func textChanged(_ sender: Any){
        if valueTextField.text == ""{
            descLabel?.text = ""
        }else{
            descLabel?.text = valueTextField.placeholder
        }
    }
}
