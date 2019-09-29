//
//  AppServiceFactory.swift
//  Points
//
//  Created by Denis Bogatyrev on 23/09/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//

import Foundation

protocol AppServiceFactoryType: class {
    func makeAPIService() -> APIServiceType
    func makeStorageService() -> StorageServiceType
}

class AppServiceFactory: AppServiceFactoryType {
    private lazy var apiService = APIService(config: APIServiceConfiguration())
    private lazy var storageService = StorageService(dataBase: makeDataBase())
    
    func makeAPIService() -> APIServiceType {
        return apiService
    }
    
    func makeStorageService() -> StorageServiceType {
        return storageService
    }
    
    private func makeDataBase() -> PersistDataBaseType {
        return PersistDataBase()
    }
}
