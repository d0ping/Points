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
    var partners: [PartnerModel] { get }
    func prepareDataIfNeeded(_ completion: @escaping () -> Void)
    func obtainCachedPoints() -> [PointModel]
    func loadPoints(for location: CLLocationCoordinate2D, radius: Int, completion: @escaping ([PointModel]) -> Void)
}

final class MapInteractor: MapInteractorType {
    private let apiService: APIServiceType
    private let storageService: StorageServiceType
    private let imageProvider: ImageProviderType
    
    private var visiblePointsIds: Set<String> = []
    
    init(apiService: APIServiceType, storageService: StorageServiceType, imageProvider: ImageProviderType) {
        self.apiService = apiService
        self.storageService = storageService
        self.imageProvider = imageProvider
    }
    
    var partners: [PartnerModel] { return storageService.allPartners() }
    
    func prepareDataIfNeeded(_ completion: @escaping () -> Void) {
        guard storageService.partnersIsEmpty else {
            preparePartnersImages(completion)
            return
        }
        
        loadPartners { [weak self] partners in
            self?.storageService.appendPartners(partners)
            self?.preparePartnersImages(completion)
        }
    }
    
    func preparePartnersImages(_ completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let loadGroup = DispatchGroup()
            self.partners.forEach { partner in
                loadGroup.enter()
                self.imageProvider.obtainImage(with: partner.picture, partnerId: partner.id) { _ in
                    loadGroup.leave()
                }
            }
            loadGroup.wait()
            DispatchQueue.main.async {
                completion()
            }
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
                guard let modelList = PartnerListModel(jsonObject: json) else { return }
                completion(modelList.payload)
            case _: break
            }
        }
    }
    
    private func loadPoints(_ coordinate: CLLocationCoordinate2D, _ radius: Int, completion: @escaping ([PointModel]) -> Void) {
        let endpoint = APIEndpoint.depositionPoints(latitude: coordinate.latitude, longitude: coordinate.longitude, radius: radius)
        apiService.request(endpoint) { result in
            switch result {
            case .success(let json):
                guard let modelList = PointListModel(jsonObject: json) else { return }
                print("--- count \(modelList.payload.count)")
                completion(modelList.payload)
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
