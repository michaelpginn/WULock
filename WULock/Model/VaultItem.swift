//
//  VaultItem.swift
//  WUSTL Secure AR
//
//  Created by Michael Ginn on 11/12/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit
import CoreData

enum ItemType:String{
    case studentID = "Student ID"
    case mailbox = "Mailbox"
    case gymLocker = "Gym Locker"
    case housing = "Housing"
    case online = "Online"
    case other = "Other"
    case none
}

typealias ItemField = (String, String)

class VaultItem: NSObject {
    var type:ItemType
    private var fields:[ItemField]
    
    
    init(type:ItemType, fields:[ItemField]){
        self.type = type
        self.fields = fields
    }
    
    /**
     Initializes a VaultItem given an NSManagedObject, which should be of the "Item" entity. If it is not, fields are set to default values
     - parameter managedObject: The managed object to use when creating the object
     */
    init(managedObject:NSManagedObject){
        if let typeIndex = managedObject.value(forKey: "type") as? String{
            self.type = ItemType(rawValue: typeIndex) ?? .none
            if self.type == .other{
                //self.otherType = managedObject.value(forKey: "other_type") as? String ?? ""
            }
        }else{
            self.type = .none
        }
        
        if let fieldsData = managedObject.value(forKey: "fields") as? [ItemField]{
            self.fields = fieldsData
        }else{
            self.fields = []
        }
    }
    
    /**
     Adds a field given a description and a value
     - parameter desc: The description string for the field, i.e. "ID Number"
     - parameter val: The value of the field, i.e. "123456"
     */
    func addField(desc: String, val: String){
        fields.append((desc, val))
    }
}
