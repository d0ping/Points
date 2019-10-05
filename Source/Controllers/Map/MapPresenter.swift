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
    private var isFirstPositioningDone: Bool = false
    
    init(interactor: MapInteractorType, builder: MapAnnotationBuilderType, router: MapRouterType, locationService: LocationServiceType) {
        self.interactor = interactor
        self.builder = builder
        self.router = router
        self.locationService = locationService
    }
    
    func setup(_ mapView: MKMapView) {
        self.mapView = mapView
        mapView.delegate = self
        
        locationService.addObserver(self)
        
        registerMapAnnotationViews()
        interactor.prepareDataIfNeeded { [weak self] in
            guard let strongSelf = self else { return }
            let points = strongSelf.interactor.obtainCachedPoints()
            strongSelf.addAnnotations(at: points)
        }
    }
    
    private func registerMapAnnotationViews() {
        guard let mapView = mapView else { return }
        mapView.register(PointAnnotationView.self, forAnnotationViewWithReuseIdentifier: PointAnnotation.reuseIdentifier)
    }
    
    func zoomIn() {
        zoom(scale: 0.5)
    }
    
    func zoomOut() {
        zoom(scale: 2)
    }
    
    private func zoom(scale coef: Double) {
        guard let center = mapView?.region.center, let span = mapView?.region.span else { return }
        let newSpan = MKCoordinateSpan(latitudeDelta: span.latitudeDelta * coef, longitudeDelta: span.longitudeDelta * coef)
        let region = MKCoordinateRegion(center: center, span: newSpan)
        mapView?.setRegion(region, animated: true)
    }
    
    func moveToCurrentLocation() {
        moveToCurrentLocation(animated: true)
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
        if isFirstPositioningDone { return }
        moveToCurrentLocation(animated: true)
        isFirstPositioningDone = true
    }
    
    private func moveToCurrentLocation(animated: Bool) {
        guard let mapView = mapView, let center = locationService.currentLocation?.coordinate else { return }
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: animated)
    }
}

extension MapPresenter: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print(mapView.region)
        if isFirstPositioningDone == false { return }
        loadPointsForCurrentMapRegion()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation.isKind(of: MKUserLocation.self) == false else { return nil }
        
        if let annotation = annotation as? PointAnnotation {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: PointAnnotation.reuseIdentifier,
                                                                          for: annotation)
            if let pointAnnotationView = annotationView as? PointAnnotationView {
                pointAnnotationView.callPhoneClosure = { [weak self] tel in
                    self?.router.callPhone(tel)
                }
                pointAnnotationView.openUrlClosure = { [weak self] url in
                    self?.router.openWebSite(url)
                }
            }
            return annotationView
        }
        return nil
    }
}
