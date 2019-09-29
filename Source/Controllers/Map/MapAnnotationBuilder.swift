//
//  MapAnnotationBuilder.swift
//  Points
//
//  Created by Denis Bogatyrev on 29/09/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//

import Foundation
import MapKit

protocol MapAnnotationBuilderType: class {
    func buildAnnotation(at points: [PointModel]) -> [MKPointAnnotation]
}

class MapAnnotationBuilder: MapAnnotationBuilderType {
    func buildAnnotation(at points: [PointModel]) -> [MKPointAnnotation] {
        return points.map { point in
            let annotation = MKPointAnnotation()
            annotation.title = point.partnerName
            annotation.subtitle = point.fullAddress
            annotation.coordinate = point.location
            return annotation
        }
    }
}
