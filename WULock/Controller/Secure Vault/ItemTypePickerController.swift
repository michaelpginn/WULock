//
//  ItemTypePickerController.swift
//  WULock
//
//  Created by Michael Ginn on 11/26/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit

protocol ItemTypePickerControllerDelegate{
    func optionSelected(type:ItemType)
}

class ItemTypePickerController: UIViewController {
    @IBOutlet var optionViews: [TypeOptionView]!
    
    //Contains an array of the info for each field so we can hardcode it
    //Should be of the structure (type_name, image_name, array_of_fields)
    
    var delegate:ItemTypePickerControllerDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpHardcodedVals()
        
        //set last view
        if let last = optionViews.last{
            self.setSelected(selectedView: last)
            if delegate != nil{
                delegate!.optionSelected(type:last.type)
            }
        }
        
    }
    

    convenience init(){
        self.init(nibName: "ItemTypePickerView", bundle: nil)
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        self.modalPresentationStyle = .none
    }

    /**
     Assigns a type to each optionView
     */
    private func setUpHardcodedVals(){
        let types:[ItemType] = [.studentID, .mailbox, .gymLocker, .online, .housing, .other]
        for i in 0..<optionViews.count{
            let ov = optionViews[i]
            ov.type = types[i]
        }
    }
    
    /**
     Marks the given optionView as selected, while deselecting all the other optionViews
     */
    private func setSelected(selectedView:TypeOptionView){
        selectedView.setSelected(true)
        for otherView in optionViews where otherView != selectedView{
            otherView.setSelected(false)
        }
    }
    
    @IBAction func tapped(_ sender: UITapGestureRecognizer) {
        //The picker was tapped somewhere, figure out if it was on a view and if so select that view
        let loc = sender.location(in: view)
        if let tappedView = view.hitTest(loc, with: nil) as? TypeOptionView, optionViews.contains(tappedView){
            
            self.setSelected(selectedView: tappedView)
            
            if delegate != nil{
                delegate!.optionSelected(type: tappedView.type)
            }
        }
    }
    
}
