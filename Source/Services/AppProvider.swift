//
//  AppProvider.swift
//  Points
//
//  Created by Denis Bogatyrev on 24/09/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//

import Foundation

class AppProvider {
    let serviceFactory: AppServiceFactoryType
    let screenFactory: AppScreenFactoryType
    
    static let shared: AppProvider = {
        let services = AppServiceFactory()
        let screens = AppScreenFactory(serviceFactory: services)
        return AppProvider(serviceFactory: services, screenFactory: screens)
    }()
    
    private init(serviceFactory: AppServiceFactoryType, screenFactory: AppScreenFactoryType) {
        self.serviceFactory = serviceFactory
        self.screenFactory = screenFactory
        
        let cache = URLCache(memoryCapacity: 4*1024*1024, diskCapacity: 40*1024*1024, diskPath: nil)
        URLCache.shared = cache
    }
}
