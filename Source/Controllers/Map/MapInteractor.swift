//
//  MapInteractor.swift
//  Points
//
//  Created by Denis Bogatyrev on 28/09/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//

import UIKit
import CoreLocation

typealias PointListModel = ListModel<PointModel>
typealias PartnerListModel = ListModel<PartnerModel>

protocol MapInteractorType: class {
    func prepareDataIfNeeded(_ completion: @escaping () -> Void)
    func obtainCachedPoints() -> [PointModel]
    func loadPoints(for location: CLLocationCoordinate2D, radius: Int, completion: @escaping ([PointModel]) -> Void)
}

final class MapInteractor: MapInteractorType {
    private let apiService: APIServiceType
    private let storageService: StorageServiceType
    private let imagePreparer: ImagePreparerType
    
    private var visiblePointsIds: Set<String> = []
    
    init(apiService: APIServiceType, storageService: StorageServiceType, imagePreparer: ImagePreparerType) {
        self.apiService = apiService
        self.storageService = storageService
        self.imagePreparer = imagePreparer
    }
    
    func prepareDataIfNeeded(_ completion: @escaping () -> Void) {
        guard storageService.partnersIsEmpty else {
            imagePreparer.prepareImages(for: storageService.allPartners(),
                                        completion: completion)
            return
        }
        
        loadPartners { [weak self] partners in
            self?.storageService.appendPartners(partners)
            self?.imagePreparer.prepareImages(for: partners, completion: completion)
        }
    }
    
    func obtainCachedPoints() -> [PointModel] {
        let models = storageService.allPoints()
        models.forEach { visiblePointsIds.insert($0.externalId) }
        return models
    }
    
    func loadPoints(for location: CLLocationCoordinate2D, radius: Int, completion: @escaping ([PointModel]) -> Void) {
        loadPoints(location, radius) { [weak self] points in
            self?.filterUnique(points, completion: { uniquePoints in
                self?.storageService.appendPoints(points, completion: {
                    let storedPoints = self?.storageService.points(at: uniquePoints.map { $0.externalId })
                    completion(storedPoints ?? [])
                })
            })
        }
    }
    
    private func loadPartners(_ completion: @escaping ([PartnerModel]) -> Void) {
        let endpoint = APIEndpoint.depositionPartners(accountType: .credit)
        apiService.request(endpoint) { result in
            switch result {
            case .success(let json):
                let partners = PartnerListModel(jsonObject: json)?.payload ?? []
                completion(partners)
            case _: break
            }
        }
    }
    
    private func loadPoints(_ coordinate: CLLocationCoordinate2D, _ radius: Int, completion: @escaping ([PointModel]) -> Void) {
        let endpoint = APIEndpoint.depositionPoints(latitude: coordinate.latitude, longitude: coordinate.longitude, radius: radius)
        apiService.request(endpoint) { result in
            switch result {
            case .success(let json):
                let points = PointListModel(jsonObject: json)?.payload ?? []
                completion(points)
            case _:
                completion([])
                break
            }
        }
    }
    
    private func filterUnique(_ points: [PointModel], completion: ([PointModel]) -> Void) {
        let uniquePoints = points.filter { visiblePointsIds.contains($0.externalId) == false }
        uniquePoints.forEach { visiblePointsIds.insert($0.externalId) }
        completion(uniquePoints)
    }
}
