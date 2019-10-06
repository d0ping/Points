//
//  ManagedObjectConvertableProtocol.swift
//  Points
//
//  Created by Denis Bogatyrev on 06/10/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//

import Foundation
import CoreData

enum ManagedObjectConvertableError: Error {
    case invalidManagedObjectType
    case invalidKeyPath
}

protocol ManagedObjectConvertable {
    static var entityName: String { get }
    init(managedObject: NSManagedObject) throws
    func fill(managedObject: NSManagedObject, in context: NSManagedObjectContext) throws
    static func updateField<Model, Value>(with keyPath: KeyPath<Model, Value>,
                                          value: Value?,
                                          managedObject: NSManagedObject,
                                          in context: NSManagedObjectContext) throws
}

extension ManagedObjectConvertable {
    static func updateField<Model, Value>(with keyPath: KeyPath<Model, Value>,
                                          value: Value?,
                                          managedObject: NSManagedObject,
                                          in context: NSManagedObjectContext) throws { }
}
