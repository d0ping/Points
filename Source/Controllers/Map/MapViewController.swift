//
//  ViewController.swift
//  Points
//
//  Created by Denis Bogatyrev on 22/09/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//

import UIKit
import MapKit

final class MapViewController: UIViewController {

    @IBOutlet private var mapView: MKMapView!
    @IBOutlet private var zoomInButton: UIButton!
    @IBOutlet private var zoomOutButton: UIButton!
    @IBOutlet private var locationButton: UIButton!
    
    private var presenter: MapPresenterType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureModule()
    }
    
    private func configureModule() {
        presenter = screenFactory.makeMapPresenter()
        presenter?.setup(self.mapView)
    }
  
    // MARK: - Actions
    @IBAction func zoomInButtonDidSelect(_ sender: UIButton) {
        presenter?.zoomIn()
    }
    
    @IBAction func zoomOutButtonDidSelect(_ sender: UIButton) {
        presenter?.zoomOut()
    }
    
    @IBAction func locationButtonDidSelect(_ sender: UIButton) {
        presenter?.moveToCurrentLocation(animated: true)
    }
}
