//
//  AppServiceFactory.swift
//  Points
//
//  Created by Denis Bogatyrev on 23/09/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//

import Foundation

protocol AppServiceFactoryType: class {
    var apiService: APIServiceType { get }
    var storageService: StorageServiceType { get }
    var locationService: LocationServiceType { get }
}

class AppServiceFactory: AppServiceFactoryType {
    private let defaultAPIConfiguration = APIConfiguration()
    
    lazy var apiService: APIServiceType = APIService()
    lazy var storageService: StorageServiceType = StorageService(dataBase: PersistDataBase())
    lazy var locationService: LocationServiceType = LocationService()
    
    func makeImageProvider() -> ImageProviderType {
        let urlBuilder = ImageURLBuilder(configuration: defaultAPIConfiguration)
        return ImageProvider(loader: ImageLoaderService(),
                             storage: storageService,
                             urlBuilder: urlBuilder)
    }
}
