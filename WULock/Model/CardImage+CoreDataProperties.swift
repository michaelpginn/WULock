//
//  CardImage+CoreDataProperties.swift
//  WULock
//
//  Created by Michael Ginn on 11/13/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//
//

import Foundation
import CoreData


extension CardImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CardImage> {
        return NSFetchRequest<CardImage>(entityName: "CardImage")
    }

    @NSManaged public var imagedata: NSData?
    @NSManaged public var type: String?

    static let FRONT_IMAGE_TYPE = "front"
    static let BACK_IMAGE_TYPE = "back"
}
