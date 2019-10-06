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
    func appendPoints(_ points: [PointModel], completion: @escaping () -> Void)
    func appendPartners(_ partners: [PartnerModel])
    func allPartners() -> [PartnerModel]
    func allPoints() -> [PointModel]
    func points(at identifiers: [String]) -> [PointModel]
    func partners(at identifiers: [String]) -> [PartnerModel]
    func saveImage(_ image: UIImage, annotationImage: UIImage, with identifiier: String, partnerId: String)
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
    
    // MARK: Points
    func appendPoints(_ points: [PointModel], completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let saveGroup = DispatchGroup()
            points.forEach { [weak self] point in
                saveGroup.enter()
                self?.save(point, completion: { _ in
                    saveGroup.leave()
                })
            }
            saveGroup.wait()
            DispatchQueue.main.async { [weak self] in
                let partnerIds = points.reduce(into: []) { !$0.contains($1.partnerName) ? $0.append($1.partnerName) : () }
                self?.associate(partners: partnerIds, completion: completion)
            }
        }
    }
    
    func allPoints() -> [PointModel] {
        return dataBase.getObjects(with: EntitySearchable(entityName: PointModel.entityName),
                                   of: PointModel.self).map { $0.object }
    }
    
    func points(at identifiers: [String]) -> [PointModel] {
        if identifiers.isEmpty { return [] }
        let format = identifiers.map { _ in "externalId == %@" }.joined(separator: " || ")
        return dataBase.getObjects(with: EntitySearchable(entityName: PointModel.entityName,
                                                          predicate: NSPredicate(format: format, argumentArray: identifiers)),
                                   of: PointModel.self).map { $0.object }
    }
    
    // MARK: Partners
    func appendPartners(_ partners: [PartnerModel]) {
        partners.forEach { [weak self] partner in
            self?.save(partner, completion: nil)
        }
    }
    
    func allPartners() -> [PartnerModel] {
        return dataBase.getObjects(with: EntitySearchable(entityName: PartnerModel.entityName),
                                   of: PartnerModel.self).map { $0.object }
    }
    
    func partners(at identifiers: [String]) -> [PartnerModel] {
        if identifiers.isEmpty { return [] }
        let format = identifiers.map { _ in "id == %@" }.joined(separator: " || ")
        return dataBase.getObjects(with: EntitySearchable(entityName: PartnerModel.entityName,
                                                          predicate: NSPredicate(format: format, argumentArray: identifiers)),
                                   of: PartnerModel.self).map { $0.object }
    }
    
    // MARK: Images
    func saveImage(_ image: UIImage, annotationImage: UIImage, with identifiier: String, partnerId: String) {
        let model = ImageModel(identifier: identifiier, image: image, annotationImage: annotationImage, lastModified: Date())
        save(model) { [weak self] result in
            if case .success = result {
                self?.associate(model, with: partnerId, completion: nil)
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
    
    private func associate(_ image: ImageModel, with partnerId: String, completion: PersistDataBaseCompletion?) {
        dataBase.updateFields(keyPath: \PartnerModel.image,
                              of: PartnerModel.self,
                              newValue: image,
                              condition: EntitySearchable(entityName: PartnerModel.entityName,
                                                          predicate: NSPredicate(format: "id == %@", partnerId)),
                              completion: completion)
    }
    
    private func associate(partners ids: [String], completion: @escaping () -> Void) {
        if ids.isEmpty {
            completion()
            return
        }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let group = DispatchGroup()
            self?.partners(at: ids).forEach({ partner in
                group.enter()
                self?.associate(partner, completion: { _ in
                    group.leave()
                })
            })
            group.wait()
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    private func associate(_ partner: PartnerModel, completion: PersistDataBaseCompletion?) {
        dataBase.updateFields(keyPath: \PointModel.partner,
                              of: PointModel.self,
                              newValue: partner,
                              condition: EntitySearchable(entityName: PointModel.entityName,
                                                          predicate: NSPredicate(format: "partnerName == %@ && partner == nil", partner.id)),
                              completion: completion)
    }
}
