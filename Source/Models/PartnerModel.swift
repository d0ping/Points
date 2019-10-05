//
//  PartnerModel.swift
//  Points
//
//  Created by Denis Bogatyrev on 28/09/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//

import Foundation
import CoreData

struct PartnerModel: JSONObjectDecodable {
    let id: String
    let name: String
    let picture: String
    let pointType: String
    let url: URL?
    let image: ImageModel?
    
    init?(jsonObject: JSONObject) {
        guard let id = jsonObject["id"] as? String else { return nil }
        guard let name = jsonObject["name"] as? String else { return nil }
        guard let picture = jsonObject["picture"] as? String else { return nil }
        guard let pointType = jsonObject["pointType"] as? String else { return nil }
        
        self.id = id
        self.name = name
        self.picture = picture
        self.pointType = pointType
        
        let urlStr = jsonObject["url"] as? String ?? ""
        let url = URL(string: urlStr)
        self.url = url
        self.image = nil
    }
}

extension PartnerModel: ManagedObjectConvertable {
    static var entityName: String {
        return "PartnerEntity"
    }
    
    init(managedObject: NSManagedObject) throws {
        guard let entity = managedObject as? PartnerEntity else { throw ManagedObjectConvertableError.invalidManagedObjectType }
        
        self.id = entity.id ?? ""
        self.name = entity.name ?? ""
        self.picture = entity.icon ?? ""
        self.pointType = entity.pointType ?? ""
        self.url = entity.url
        self.image = try entity.image.map({ try ImageModel(managedObject: $0) })
    }
    
    func fill(managedObject: NSManagedObject, in context: NSManagedObjectContext) throws {
        guard let entity = managedObject as? PartnerEntity else { throw ManagedObjectConvertableError.invalidManagedObjectType }
        
        entity.id = self.id
        entity.name = self.name
        entity.icon = self.picture
        entity.pointType = self.pointType
        entity.url = self.url
    }
    
    static func updateField<Model, Value>(with keyPath: KeyPath<Model, Value>, value: Value?, managedObject: NSManagedObject, in context: NSManagedObjectContext) throws {
        guard let keyPath = keyPath as? KeyPath<PartnerModel, Value> else { throw ManagedObjectConvertableError.invalidKeyPath }
        guard let object = managedObject as? PartnerEntity else { throw ManagedObjectConvertableError.invalidManagedObjectType }
        switch keyPath {
        case \PartnerModel.image:
            if let prev = object.image {
                context.delete(prev)
                object.image = nil
            }
            if let newModel = value as? ImageModel {
                let newObject = ImageEntity(context: context)
                try newModel.fill(managedObject: newObject, in: context)
                object.image = newObject
                newObject.partner = object
            }
        default:
            break
        }
    }
}
