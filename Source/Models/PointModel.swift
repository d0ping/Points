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
    let phones: String
    let location: CLLocationCoordinate2D
    let partner: PartnerModel?
    
    init?(jsonObject: JSONObject) {
        guard let externalId = jsonObject["externalId"] as? String else { return nil }
        guard let partnerName = jsonObject["partnerName"] as? String else { return nil }
        guard let workHours = jsonObject["workHours"] as? String else { return nil }
        guard let fullAddress = jsonObject["fullAddress"] as? String else { return nil }
        guard let phones = jsonObject["phones"] as? String else { return nil }
        guard let location = jsonObject["location"] as? JSONObject,
            let latitude = location["latitude"] as? Double,
            let longitude = location["longitude"] as? Double else { return nil }
        
        self.externalId = externalId
        self.partnerName = partnerName
        self.workHours = workHours
        self.fullAddress = fullAddress
        self.phones = phones
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
       
        self.externalId = entity.externalId ?? ""
        self.partnerName = entity.partnerName ?? ""
        self.workHours = entity.workHours ?? ""
        self.fullAddress = entity.fullAddress ?? ""
        self.phones = entity.phones ?? ""
        self.location = CLLocationCoordinate2D(latitude: entity.latitude, longitude: entity.longitude)
        self.partner = try entity.partner.map({ try PartnerModel(managedObject: $0) })
    }
    
    func fill(managedObject: NSManagedObject, in context: NSManagedObjectContext) throws {
        guard let entity = managedObject as? PointEntity else { throw ManagedObjectConvertableError.invalidManagedObjectType }
        
        entity.externalId = self.externalId
        entity.partnerName = self.partnerName
        entity.workHours = self.workHours
        entity.fullAddress = self.fullAddress
        entity.phones = self.phones
        entity.latitude = self.location.latitude
        entity.longitude = self.location.longitude
    }
    
    static func updateField<Model, Value>(with keyPath: KeyPath<Model, Value>, value: Value?, managedObject: NSManagedObject, in context: NSManagedObjectContext) throws {
        guard let keyPath = keyPath as? KeyPath<PointModel, Value> else { throw ManagedObjectConvertableError.invalidKeyPath }
        guard let object = managedObject as? PointEntity else { throw ManagedObjectConvertableError.invalidManagedObjectType }
        switch keyPath {
        case \PointModel.partner:
            if let prev = object.partner {
                context.delete(prev)
                object.partner = nil
            }
            if let newModel = value as? PartnerModel {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: PartnerModel.entityName)
                fetchRequest.predicate = NSPredicate(format: "id == %@", newModel.id)
                
                let fetchedObjects = try context.fetch(fetchRequest)
                let partnerObject = fetchedObjects.first as? PartnerEntity ?? PartnerEntity(context: context)
                
                try newModel.fill(managedObject: partnerObject, in: context)
                object.partner = partnerObject
                partnerObject.addToPoints(object)
            }
        default:
            break
        }
    }
}
