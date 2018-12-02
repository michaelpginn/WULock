//
//  VaultItem.swift
//  WUSTL Secure AR
//
//  Created by Michael Ginn on 11/12/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit
import CoreData



class VaultItem: NSObject {
    var type:ItemType
    private var fields:[ItemField]
    
    static let ITEM_DESCRIPTION_KEY = "Item description"
    
    /**
     Initializes a VaultItem with a type and a list of fields, where each field has a description and value
     - parameter type: The type of item
     - parameter fields: An array of ItemField objects
     */
    init(type:ItemType, fields:[ItemField]){
        self.type = type
        self.fields = fields
    }
    
    override var description: String {
        if type != .other{
            return type.rawValue
        }else{
            return self.get(desc: VaultItem.ITEM_DESCRIPTION_KEY) ?? ""
        }
    }
    
    //MARK: Core Data
    
    /**
     Initializes a VaultItem given an NSManagedObject, which should be of the "Item" entity. If it is not, fields are set to default values
     - parameter managedObject: The managed object to use when creating the object
     */
    init(managedObject:NSManagedObject){
        if let typeIndex = managedObject.value(forKey: "type") as? String{
            self.type = ItemType(rawValue: typeIndex) ?? .none
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
    Returns a managed object, inserted into the given context, for the current VaultItem object.
     - parameter context: The NSManagedObjectContext into which the new item will be inserted
     */
    func getManagedObject(context:NSManagedObjectContext)->NSManagedObject{
        if let entity = NSEntityDescription.entity(forEntityName: "Item", in: context) {
            let newMO = NSManagedObject(entity: entity, insertInto: context)
            newMO.setValue(type.rawValue, forKey: "type")
            newMO.setValue(fields, forKey: "fields")
            return newMO
        }else{
            return NSManagedObject(context: context)
        }
    }
    
    //MARK: Set/Get fields
    
    /**
     Adds a field given a description and a value
     - parameter desc: The description string for the field, i.e. "ID Number"
     - parameter val: The value of the field, i.e. "123456"
     */
    func addField(desc: String, val: String){
        fields.append(ItemField(fieldDescription: desc, fieldValue: val))
    }
    
    /**
    Adds a field given an Item Field object
     */
    func addField(field:ItemField){
        fields.append(field)
    }
    
    /**
    Gets the value stored by the field with a given description. If multiple fields have the same description, the value from the first one will be returned.
     */
    func get(desc: String)->String?{
        for field in fields{
            if field.fieldDescription == desc{
                return field.fieldValue
            }
        }
        return nil
    }
    func getWithoutDescription()-> [ItemField]{
        return fields
    }
    
    func canParse()->Bool{
        if type == .gymLocker{
            guard let code = get(desc: "Combination") else{return false}
            guard code.count == 4 else{return false}
            guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: code)) else{return false}
            return true
        }else if type == .mailbox{
            guard let code = get(desc: "Combination") else{return false}
            let count = code.count
            guard count >= 5 && count <= 8 else{return false}
            
            //first thing better be a number
            //last thing better be a number
            //no number can be >2 digits
            let decimals = CharacterSet.decimalDigits
            let characters = Array(code.unicodeScalars)
            var letterCount:Int = 0
            var separatorCount:Int = 0
            for index in 0..<characters.count{
                if (index == 0 || index == characters.count - 1) && !decimals.contains(characters[index]){
                    return false
                }
                if decimals.contains(characters[index]){
                    letterCount += 1
                    if letterCount > 2 {return false}
                }else{
                    letterCount = 0
                    separatorCount += 1
                }
            }
            if separatorCount > 2 {return false}
            return true
        }else{
            return false
        }
    }
    
    func parse()->[Int]?{
        guard canParse()  else {return nil}
        
        
        if type == .gymLocker{
            //should be a four digit code
            if let code = get(desc: "Combination"){
                var numbers:[Int] = []
                for digit in code{
                    guard let num = Int(String(digit)) else{return nil}
                    numbers.append(num)
                }
                return numbers
            }else{return nil}
            
        }else if type == .mailbox{
            if let code = get(desc: "Combination"){
                var numbers:[Int] = []
                let decimals = CharacterSet.decimalDigits
                numbers = [0, 0, 0]
                var currentIndex = 0
                for digit in code.unicodeScalars{
                    if decimals.contains(digit){
                        guard let num = Int(String(digit)) else{return nil}
                        numbers[currentIndex] = (numbers[currentIndex] * 10) + num
                    }else{
                        currentIndex += 1
                    }
                }
                return numbers
            }else{return nil}
            
        }else{
            return nil
        }
    }
}
