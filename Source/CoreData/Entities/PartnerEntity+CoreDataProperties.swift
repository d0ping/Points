//
//  PartnerEntity+CoreDataProperties.swift
//  Points
//
//  Created by Denis Bogatyrev on 03/10/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//
//

import Foundation
import CoreData


extension PartnerEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PartnerEntity> {
        return NSFetchRequest<PartnerEntity>(entityName: "PartnerEntity")
    }

    @NSManaged public var icon: String?
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var pointType: String?
    @NSManaged public var url: URL?
    @NSManaged public var image: ImageEntity?
    @NSManaged public var points: NSSet?

}

// MARK: Generated accessors for points
extension PartnerEntity {

    @objc(addPointsObject:)
    @NSManaged public func addToPoints(_ value: PointEntity)

    @objc(removePointsObject:)
    @NSManaged public func removeFromPoints(_ value: PointEntity)

    @objc(addPoints:)
    @NSManaged public func addToPoints(_ values: NSSet)

    @objc(removePoints:)
    @NSManaged public func removeFromPoints(_ values: NSSet)

}
