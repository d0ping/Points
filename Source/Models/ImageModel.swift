//
//  ImageModel.swift
//  Points
//
//  Created by Denis Bogatyrev on 03/10/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//

import UIKit
import CoreData

struct ImageModel {
    let identifier: String
    let image: UIImage
    let annotationImage: UIImage
    let lastModified: Date
}

extension ImageModel: ManagedObjectConvertable {
    static var entityName: String { return "ImageEntity" }
    
    init(managedObject: NSManagedObject) throws {
        guard let entity = managedObject as? ImageEntity else { throw ManagedObjectConvertableError.invalidManagedObjectType }
        
        self.identifier = entity.identifier ?? ""
        self.image = UIImage(data: entity.data as Data? ?? Data(capacity: 0), scale: UIScreen.main.scale) ?? UIImage()
        self.annotationImage = UIImage(data: entity.annotation as Data? ?? Data(capacity: 0), scale: UIScreen.main.scale) ?? UIImage()
        self.lastModified =  entity.lastModified as Date? ?? Date()
    }
    
    func fill(managedObject: NSManagedObject, in context: NSManagedObjectContext) throws {
        guard let entity = managedObject as? ImageEntity else { throw ManagedObjectConvertableError.invalidManagedObjectType }
        
        entity.identifier = self.identifier
        entity.data = self.image.pngData() as NSData?
        entity.annotation = self.annotationImage.pngData() as NSData?
        entity.lastModified = self.lastModified as NSDate
    }
    
    static func updateField<Model, Value>(with keyPath: KeyPath<Model, Value>,
                                          value: Value?,
                                          managedObject: NSManagedObject,
                                          in context: NSManagedObjectContext) throws {
    }
}
