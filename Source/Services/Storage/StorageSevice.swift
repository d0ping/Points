//
//  StorageSevice.swift
//  Points
//
//  Created by Denis Bogatyrev on 22/09/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//

import UIKit
import CoreLocation

protocol StorageServiceType: class {
    var partnersIsEmpty: Bool { get }
    func appendPoints(_ points: [PointModel])
    func appendPartners(_ partners: [PartnerModel])
    func allPartners() -> [PartnerModel]
    func allPoints() -> [PointModel]
    func partners(at identifiers: [String]) -> [PartnerModel]
    func saveImage(_ image: UIImage, with identifiier: String, partnerId: String)
    func fetchImage(at identifier: String) -> ImageModel?
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
    
    func allPartners() -> [PartnerModel] {
        return dataBase.getObjects(with: EntitySearchable(entityName: PartnerModel.entityName),
                                   of: PartnerModel.self).map { $0.object }
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
    
    func saveImage(_ image: UIImage, with identifiier: String, partnerId: String) {
        let model = ImageModel(identifier: identifiier, image: image, lastModified: Date())
        save(model) { [weak self] result in
            switch result {
            case .success: self?.associateIfNeeded(model, with: partnerId, completion: nil)
            case .failure: break
            }
        }
    }
    
    func fetchImage(at identifier: String) -> ImageModel? {
        return dataBase.getObjects(with: EntitySearchable(entityName: ImageModel.entityName,
                                                          predicate: NSPredicate(format: "identifier == %@", identifier)),
                                   of: ImageModel.self).map { $0.object }.first
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
    
    private func save(_ image: ImageModel, completion: PersistDataBaseCompletion?) {
        dataBase.update(object: EntityRepresentable(entityName: ImageModel.entityName, object: image),
                        with: EntitySearchable(entityName: ImageModel.entityName,
                                               predicate: NSPredicate(format: "identifier == %@", image.identifier)),
                        completion: completion)
    }
    
    private func associateIfNeeded(_ image: ImageModel, with partnerId: String, completion: PersistDataBaseCompletion?) {
        guard let partner = partners(at: [partnerId]).first else { return }
        dataBase.updateFields(keyPath: \PartnerModel.image,
                              of: PartnerModel.self,
                              newValue: image,
                              condition: EntitySearchable(entityName: PartnerModel.entityName,
                                                          predicate: NSPredicate(format: "id == %@", partnerId)),
                              completion: completion)
    }
}
