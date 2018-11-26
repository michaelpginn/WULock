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

class VaultItem: NSObject {
    var type:ItemType
    var otherType:String?
    private var fields:[String:String]
    
    
    init(type:ItemType, fields:[String:String]){
        self.type = type
        self.fields = fields
    }
    
    init(managedObject:NSManagedObject){
        if let typeIndex = managedObject.value(forKey: "type") as? String{
            self.type = ItemType(rawValue: typeIndex) ?? .none
            if self.type == .other{
                self.otherType = managedObject.value(forKey: "other_type") as? String ?? ""
            }
        }else{
            self.type = .none
        }
        
        if let fieldsData = managedObject.value(forKey: "fields") as? [String:String]{
            self.fields = fieldsData
        }else{
            self.fields = [:]
        }
    }
    
    func addField(desc: String, val: String){
        fields[desc] = val
    }
}
