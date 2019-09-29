//
//  Point.swift
//  Points
//
//  Created by Denis Bogatyrev on 26/09/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData

struct PointModel: JSONObjectDecodable {
    let externalId: String
    let partnerName: String
    let workHours: String
    let fullAddress: String
    let location: CLLocationCoordinate2D
    let partner: PartnerModel?
    
    init?(jsonObject: JSONObject) {
        guard let externalId = jsonObject["externalId"] as? String else { return nil }
        guard let partnerName = jsonObject["partnerName"] as? String else { return nil }
        guard let workHours = jsonObject["workHours"] as? String else { return nil }
        guard let fullAddress = jsonObject["fullAddress"] as? String else { return nil }
        guard let location = jsonObject["location"] as? JSONObject,
            let latitude = location["latitude"] as? Double,
            let longitude = location["longitude"] as? Double else { return nil }
        
        self.externalId = externalId
        self.partnerName = partnerName
        self.workHours = workHours
        self.fullAddress = fullAddress
        self.location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.partner = nil
    }
}

extension PointModel: ManagedObjectConvertable {
    static var entityName: String {
        return "PointEntity"
    }
    
    init(managedObject: NSManagedObject) throws {
        guard let entity = managedObject as? PointEntity else { throw ManagedObjectConvertableError.invalidManagedObjectType }
       
        self.externalId = entity.externalId
        self.partnerName = entity.partnerName
        self.workHours = entity.workHours
        self.fullAddress = entity.fullAddress
        self.location = CLLocationCoordinate2D(latitude: entity.latitude, longitude: entity.longitude)
        self.partner = try entity.partner.map({ try PartnerModel(managedObject: $0) })
    }
    
    func fill(managedObject: NSManagedObject, in context: NSManagedObjectContext) throws {
        guard let entity = managedObject as? PointEntity else { throw ManagedObjectConvertableError.invalidManagedObjectType }
        
        entity.externalId = self.externalId
        entity.partnerName = self.partnerName
        entity.workHours = self.workHours
        entity.fullAddress = self.fullAddress
        entity.latitude = self.location.latitude
        entity.longitude = self.location.longitude
    }
}
