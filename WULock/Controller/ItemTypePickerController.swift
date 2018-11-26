//
//  ItemTypePickerController.swift
//  WULock
//
//  Created by Michael Ginn on 11/26/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit

class ItemTypePickerController: UIViewController {
    @IBOutlet var optionViews: [TypeOptionView]!
    
    private var optionInfo:[(String, String, [String])] = [] //Contains an array of the info for each field so we can hardcode it
    //Should be of the structure (type_name, image_name, array_of_fields)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    convenience init(){
        self.init(nibName: "ItemTypePickerView", bundle: nil)
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        self.modalPresentationStyle = .none
        
        
    }

    private func setUpHardcodedVals(){
        optionInfo = []
        optionInfo.append(("Student ID", "icon_studentID", [
            "Name", "ID Number", "Academic Division", "Date"]))
        optionInfo.append(("Mailbox", "icon_mailbox", [
            "Mailbox Number", "Combination"]))
        optionInfo.append(("Gym Locker", "icon_gym", [
            "Locker number", "Locker combination"]))
        optionInfo.append(("Online", "icon_online", [
            "Site", "Username", "Password"]))
        optionInfo.append(("Housing", "icon_housing", [
            "Dorm", "Room number"]))
        optionInfo.append(("Other", "icon_other", ["Description"]))
        
        for i in 0..<optionViews.count{
            let ov = optionViews[i]
            ov.title = optionInfo[i].0
            ov.iconImage = UIImage(named: optionInfo[i].1)
        }
    }
}
