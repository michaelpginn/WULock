//
//  ItemType.swift
//  WULock
//
//  Created by Michael Ginn on 11/27/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import Foundation
import UIKit

enum ItemType:String{
    case studentID = "Student ID"
    case mailbox = "Mailbox"
    case gymLocker = "Gym Locker"
    case housing = "Housing"
    case online = "Online"
    case other = "Other"
    case none
    
    /**
     Gets the associated image for the given type
     */
    func getImage()->UIImage{
        if let imageName = getImageName(){
            return UIImage(named: imageName) ?? UIImage()
        }else{
            return UIImage()
        }
    }
    
    func getImageName()->String?{
        switch self{
        case .studentID:
            return "icon_studentID"
        case .mailbox:
            return "icon_mailbox"
        case .gymLocker:
            return "icon_gym"
        case .housing:
            return "icon_housing"
        case .online:
            return "icon_online"
        case .other:
            return "icon_other"
        case .none:
            return nil
        }
    }
    
    /**
     Gets the descriptions for the fields which must be included for the given type
     */
    func getDefaultFields()->[String]{
        switch self{
        case .studentID:
            return [
                "Name", "ID Number", "Academic Division", "Date"]
        case .mailbox:
            return [
                "Mailbox Number", "Combination"]
        case .gymLocker:
            return [
                "Locker Number", "Combination"]
        case .housing:
            return [
                "Dorm", "Room number"]
        case .online:
            return [
                "Site", "Username", "Password"]
        case .other:
            return [VaultItem.ITEM_DESCRIPTION_KEY]
        case .none:
            return []
        }
    }
}
