//
//  PointAnnotationView.swift
//  Points
//
//  Created by Denis Bogatyrev on 30/09/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//

import MapKit

class PointAnnotation: NSObject, MKAnnotation {
    
    static let reuseIdentifier = NSStringFromClass(PointAnnotation.self) as String
    
    @objc dynamic var coordinate: CLLocationCoordinate2D
    
    var partnerId: String?
    var title: String?
    var subtitle: String?
    
    var image: UIImage?
    var fullAddress: String?
    var workHours: String?
    
    var url: URL?
    var tel: String?
    
    init(coordinate: CLLocationCoordinate2D,
         partnerId: String?,
         title: String?,
         subtitle: String?,
         image: UIImage?,
         fullAddress: String?,
         workHours: String?,
         url: URL?, tel: String?)
    {
        self.coordinate = coordinate
        self.partnerId = partnerId
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.fullAddress = fullAddress
        self.workHours = workHours
        self.url = url
        self.tel = tel
    }
}
