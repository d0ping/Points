//
//  StorageSevice.swift
//  Points
//
//  Created by Denis Bogatyrev on 22/09/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//

import Foundation
import CoreLocation

protocol StorageServiceType: class {
    var partnersIsEmpty: Bool { get }
    func appendPoints(_ points: [PointModel])
    func appendPartners(_ partners: [PartnerModel])
    func allPoints() -> [PointModel]
    func partners(at identifiers: [String]) -> [PartnerModel]
}

final class StorageService: StorageServiceType {
    private let dataBase: PersistDataBaseType
    
    init(dataBase: PersistDataBaseType) {
        self.dataBase = dataBase
    }
    
    var partnersIsEmpty: Bool {
        return self.dataBase.countOfObjects(with: EntitySearchable(entityName: PartnerModel.entityName)) == 0
    }
    
    func appendPoints(_ points: [PointModel]) {
        points.forEach { [weak self] point in
            self?.save(point, completion: nil)
        }
    }
    
    func appendPartners(_ partners: [PartnerModel]) {
        partners.forEach { [weak self] partner in
            self?.save(partner, completion: nil)
        }
    }
    
    func allPoints() -> [PointModel] {
        return dataBase.getObjects(with: EntitySearchable(entityName: PointModel.entityName),
                                   of: PointModel.self).map { $0.object }
    }
    
    func partners(at identifiers: [String]) -> [PartnerModel] {
        let format = identifiers.map { _ in "id == %@" }.joined(separator: " || ")
        return dataBase.getObjects(with: EntitySearchable(entityName: PartnerModel.entityName,
                                                          predicate: NSPredicate(format: format, argumentArray: identifiers)),
                                   of: PartnerModel.self).map { $0.object }
    }
    
}

extension StorageService {
    private func save(_ point: PointModel, completion: PersistDataBaseCompletion?) {
        dataBase.update(object: EntityRepresentable(entityName: PointModel.entityName, object: point),
                        with: EntitySearchable(entityName: PointModel.entityName,
                                               predicate: NSPredicate(format: "externalId == %@", point.externalId)),
                        completion: completion)
    }
    
    private func save(_ partner: PartnerModel, completion: PersistDataBaseCompletion?) {
        dataBase.update(object: EntityRepresentable(entityName: PartnerModel.entityName, object: partner),
                        with: EntitySearchable(entityName: PartnerModel.entityName,
                                               predicate: NSPredicate(format: "id == %@", partner.id)),
                        completion: completion)
    }
}
