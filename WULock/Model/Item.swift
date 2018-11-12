//
//  Item.swift
//  WUSTL Secure AR
//
//  Created by Michael Ginn on 11/12/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit

enum ItemType{
    case studentID
    case mailbox
    case gymLocker
    case housing
    case other(desc:String)
}

class Item: NSObject {
    var type:ItemType
    private var fields:[String:String]
    
    init(type:ItemType, fields:[String:String]){
        self.type = type
        self.fields = fields
    }
    
    func addField(desc: String, val: String){
        fields[desc] = val
    }
}
