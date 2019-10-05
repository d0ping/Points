//
//  AppScreenFactory.swift
//  Points
//
//  Created by Denis Bogatyrev on 24/09/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//

import Foundation

protocol AppScreenFactoryType: class {
    func makeMapPresenter() -> MapPresenterType
}

class AppScreenFactory: AppScreenFactoryType {
    private let serviceFactory: AppServiceFactoryType
    
    init(serviceFactory: AppServiceFactoryType) {
        self.serviceFactory = serviceFactory
    }
    
    // MARK: - Map controller
    func makeMapPresenter() -> MapPresenterType {
        return MapPresenter(interactor: makeMapInteractor(),
                            builder: makeMapAnnotationBuilder(),
                            router: makeMapRouter(),
                            locationService: serviceFactory.locationService)
    }
    
    private func makeMapInteractor() -> MapInteractorType {
        return MapInteractor(apiService: serviceFactory.apiService,
                             storageService: serviceFactory.storageService,
                             imageProvider: serviceFactory.makeImageProvider())
    }
    
    private func makeMapAnnotationBuilder() -> MapAnnotationBuilderType {
        return MapAnnotationBuilder()
    }
    
    private func makeMapRouter() -> MapRouterType {
        return MapRouter()
    }
}
