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
    private let router: MapRouterType
    private let locationService: LocationServiceType
    
    private weak var mapView: MKMapView?
    private var firstPositioning: Bool = false
    
    init(interactor: MapInteractorType, builder: MapAnnotationBuilderType, router: MapRouterType, locationService: LocationServiceType) {
        self.interactor = interactor
        self.builder = builder
        self.router = router
        self.locationService = locationService
    }
    
    func setup(_ mapView: MKMapView) {
        self.mapView = mapView
        mapView.delegate = self
        
        self.locationService.addObserver(self)
        
        self.registerMapAnnotationViews()
        let points = interactor.obtainCachedPoints()
        addAnnotations(at: points)
        
        interactor.prepareDataIfNeeded { [weak self] in
            self?.loadPointsForCurrentMapRegion()
        }
    }
    
    private func registerMapAnnotationViews() {
        guard let mapView = mapView else { return }
        mapView.register(PointAnnotationView.self, forAnnotationViewWithReuseIdentifier: PointAnnotation.reuseIdentifier)
    }
    
    func zoomIn() {
        loadPointsForCurrentMapRegion()
    }
    
    func zoomOut() {
        //
    }
    
    func moveToCurrentLocation() {
        guard let mapView = mapView else { return }
        mapView.setCenter(mapView.userLocation.coordinate, animated: true)
    }
    
    private func loadPointsForCurrentMapRegion() {
        guard let region = mapView?.region else { return }
        let distance = visibleRegionRadius(at: region)
        
        interactor.loadPoints(for: region.center, radius: Int(distance)) { [weak self] points in
            guard let strongSelf = self else { return }
            strongSelf.addAnnotations(at: points)
        }
    }
    
    private func addAnnotations(at points: [PointModel]) {
        guard let mapView = mapView else { return }
        mapView.addAnnotations(builder.buildAnnotations(at: points, partners: interactor.partners))
    }
    
    private func visibleRegionRadius(at region: MKCoordinateRegion) -> CLLocationDistance {
        let centerLocation = CLLocation(latitude: region.center.latitude,
                                        longitude: region.center.longitude)
        let distantLocation = CLLocation(latitude: region.center.latitude + region.span.latitudeDelta / 2,
                                         longitude: region.center.longitude + region.span.longitudeDelta / 2)
        return centerLocation.distance(from: distantLocation)
    }
}

extension MapPresenter: LocationServiceObserverType {
    func didUpdateCurrentLocations(_ location: CLLocation) {
        if firstPositioning { return }
        mapView?.setCenterCoordinate(location.coordinate, withZoomLevel: 10, animated: true)
        firstPositioning = true
    }
}

extension MapPresenter: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        
    }
}
