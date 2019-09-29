//
//  MapPresenter.swift
//  Points
//
//  Created by Denis Bogatyrev on 23/09/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//

import Foundation
import MapKit

protocol MapPresenterType: class {
    func setup(_ mapView: MKMapView)
    
    func zoomIn()
    func zoomOut()
    func moveToCurrentLocation()
}

final class MapPresenter: NSObject, MapPresenterType {
    private let interactor: MapInteractorType
    private let builder: MapAnnotationBuilderType
    
    private weak var mapView: MKMapView?
    
    init(interactor: MapInteractorType, builder: MapAnnotationBuilderType) {
        self.interactor = interactor
        self.builder = builder
    }
    
    func setup(_ mapView: MKMapView) {
        self.mapView = mapView
        mapView.delegate = self
        
        let points = interactor.obtainCachedPoints()
        mapView.addAnnotations(builder.buildAnnotation(at: points))
        
        interactor.prepareDataIfNeeded { [weak self] in
            self?.loadPpintsForCurrentMapRegion()
        }
    }
    
    func zoomIn() {
        loadPpintsForCurrentMapRegion()
    }
    
    func zoomOut() {
        //
    }
    
    func moveToCurrentLocation() {
        guard let mapView = mapView else { return }
        mapView.setCenter(mapView.userLocation.coordinate, animated: true)
    }
    
    private func loadPpintsForCurrentMapRegion() {
        guard let mapView = mapView else { return }
        interactor.loadPoints(for: mapView.region.center, radius: 1000) { [weak self] points in
            guard let strongSelf = self else { return }
            strongSelf.mapView?.addAnnotations(strongSelf.builder.buildAnnotation(at: points))
        }
    }
    
}

extension MapPresenter: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        
    }
}
