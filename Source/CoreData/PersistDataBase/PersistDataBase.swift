//
//  PersistDataBase.swift
//  Points
//
//  Created by Denis Bogatyrev on 29/09/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//

import Foundation
import CoreData

public class EntityRepresentable<T> {
    public let entityName: String
    public let object: T
    
    public init(entityName: String, object: T) {
        self.entityName = entityName
        self.object = object
    }
}

public struct EntitySearchable {
    public var entityName: String
    public var predicate: NSPredicate?
    public var sortDescriptors: [NSSortDescriptor]
    
    public init(entityName: String, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor] = [])  {
        self.entityName = entityName
        self.predicate = predicate
        self.sortDescriptors = sortDescriptors
    }
}

public enum PersistDataBaseSaveResult {
    case success
    case failure(Error)
}

public typealias PersistDataBaseCompletion = (PersistDataBaseSaveResult) -> Void

protocol PersistDataBaseType: class {
    func countOfObjects(with condition: EntitySearchable) -> Int
    func getObjects<T>(with condition: EntitySearchable, of type: T.Type) -> [EntityRepresentable<T>]
    func insert<T>(object: EntityRepresentable<T>, completion: PersistDataBaseCompletion?)
    func update<T>(object: EntityRepresentable<T>, with condition: EntitySearchable, completion: PersistDataBaseCompletion?)
    func updateFields<T, V>(keyPath: KeyPath<T, V>, of type: T.Type, newValue: V?, condition: EntitySearchable, completion: PersistDataBaseCompletion?)
}

final class PersistDataBase: PersistDataBaseType {
    private var viewContext: NSManagedObjectContext
    private var updateContext: NSManagedObjectContext
    
    private static let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    init() {
        self.viewContext = PersistDataBase.persistentContainer.viewContext
        self.viewContext.automaticallyMergesChangesFromParent = true
        self.updateContext = PersistDataBase.persistentContainer.newBackgroundContext()
        self.updateContext.automaticallyMergesChangesFromParent = true
        self.updateContext.undoManager = UndoManager()
    }
    
    private func read<T>(_ handler: (NSManagedObjectContext) -> T) -> T? {
        return handler(viewContext)
    }
    
    private func performOnUpdateContextAndSave(block: @escaping (NSManagedObjectContext) throws -> Void,
                                               saveCompletion: PersistDataBaseCompletion?) {
        let context = updateContext
        context.perform {
            do {
                try block(context)
                context.save(completion: saveCompletion)
            }
            catch {
                context.handleError(error, completion: saveCompletion)
            }
        }
    }
    
    func countOfObjects(with condition: EntitySearchable) -> Int {
        let fetchRequest = PersistDataBase.fetchRequest(from: condition)
        return read { context in
            ((try? context.count(for: fetchRequest)) ?? 0)
            } ?? 0
    }
    
    func getObjects<T>(with condition: EntitySearchable, of type: T.Type) -> [EntityRepresentable<T>] {
        guard let convertableType = type as? ManagedObjectConvertable.Type else { return [] }
        let fetchRequest = PersistDataBase.fetchRequest(from: condition)
        
        return read { context in
            ((try? context.fetch(fetchRequest)) ?? []).compactMap {
                (try? convertableType.init(managedObject: $0) as? T).map {
                    EntityRepresentable(entityName: condition.entityName, object: $0)
                }
            }
            } ?? []
    }
    
    func insert<T>(object: EntityRepresentable<T>, completion: PersistDataBaseCompletion?) {
        guard let convertableObject = object.object as? ManagedObjectConvertable else { return }
        performOnUpdateContextAndSave(block: { context in
            let managedObject = NSEntityDescription.insertNewObject(forEntityName: object.entityName, into: context)
            try convertableObject.fill(managedObject: managedObject, in: context)
        }, saveCompletion: completion)
    }
    
    func update<T>(object: EntityRepresentable<T>, with condition: EntitySearchable, completion: PersistDataBaseCompletion?) {
        guard let convertableObject = object.object as? ManagedObjectConvertable else { return }
        performOnUpdateContextAndSave(block: { context in
            let fetchRequest = PersistDataBase.fetchRequest(from: condition)
            let managedObject: NSManagedObject
            if let currentManagedObject = try? context.fetch(fetchRequest).first {
                managedObject = currentManagedObject
            } else {
                managedObject = NSEntityDescription.insertNewObject(forEntityName: object.entityName, into: context)
            }
            try convertableObject.fill(managedObject: managedObject, in: context)
        }, saveCompletion: completion)
    }
    
    func updateFields<T, V>(keyPath: KeyPath<T, V>, of type: T.Type, newValue: V?, condition: EntitySearchable, completion: PersistDataBaseCompletion?) {
        guard let convertableType = type as? ManagedObjectConvertable.Type else { return }
        performOnUpdateContextAndSave(block: { (context) in
            let fetchRequest = PersistDataBase.fetchRequest(from: condition)
            let objects = try context.fetch(fetchRequest)
            try objects.forEach({ object in
                try convertableType.updateField(with: keyPath,
                                                value: newValue,
                                                managedObject: object,
                                                in: context) })
        }, saveCompletion: completion)
    }
    
    private static func fetchRequest(from condition: EntitySearchable) -> NSFetchRequest<NSManagedObject> {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: condition.entityName)
        fetchRequest.predicate = condition.predicate
        fetchRequest.sortDescriptors = condition.sortDescriptors
        return fetchRequest
    }
}

extension NSManagedObjectContext {
    func save(completion: PersistDataBaseCompletion?) {
        guard hasChanges else {
            completion?(.success)
            return
        }
        do {
            try save()
            completion?(.success)
        }
        catch {
            handleError(error, completion: completion)
        }
    }
    
    func handleError(_ error: Error, completion: PersistDataBaseCompletion?) {
        hasChanges ? rollback() : ()
        completion?(.failure(error))
    }
}
