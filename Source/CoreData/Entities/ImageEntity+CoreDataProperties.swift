//
//  ImageEntity+CoreDataProperties.swift
//  Points
//
//  Created by Denis Bogatyrev on 03/10/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//
//

import Foundation
import CoreData


extension ImageEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageEntity> {
        return NSFetchRequest<ImageEntity>(entityName: "ImageEntity")
    }

    @NSManaged public var data: NSData?
    @NSManaged public var identifier: String?
    @NSManaged public var lastModified: NSDate?
    @NSManaged public var partner: PartnerEntity?

}
