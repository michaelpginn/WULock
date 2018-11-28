//
//  ItemField.swift
//  WULock
//
//  Created by Michael Ginn on 11/27/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit

class ItemField: NSObject, NSCoding {
    
    var fieldDescription: String
    var fieldValue: String
    
    override init() {
        fieldDescription = ""
        fieldValue = ""
    }
    
    init(fieldDescription desc:String, fieldValue val:String) {
        fieldDescription = desc
        fieldValue = val
    }
    
    required init(coder aDecoder:NSCoder){
        fieldDescription = aDecoder.decodeObject(forKey: "description") as? String ?? ""
        fieldValue = aDecoder.decodeObject(forKey: "value") as? String ?? ""
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(fieldDescription, forKey: "description")
        aCoder.encode(fieldValue, forKey: "value")
    }
}
