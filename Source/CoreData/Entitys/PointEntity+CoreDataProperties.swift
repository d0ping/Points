//
//  PointEntity+CoreDataProperties.swift
//  Points
//
//  Created by Denis Bogatyrev on 29/09/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//
//

import Foundation
import CoreData


extension PointEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PointEntity> {
        return NSFetchRequest<PointEntity>(entityName: "PointEntity")
    }

    @NSManaged public var externalId: String?
    @NSManaged public var fullAddress: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var partnerName: String?
    @NSManaged public var workHours: String?
    @NSManaged public var phones: String?
    @NSManaged public var partner: PartnerEntity?

}
