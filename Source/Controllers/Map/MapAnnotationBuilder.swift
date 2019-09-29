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
    func buildAnnotation(at points: [PointModel], partners: [PartnerModel]) -> [MKPointAnnotation]
}

class MapAnnotationBuilder: MapAnnotationBuilderType {
    func buildAnnotation(at points: [PointModel], partners: [PartnerModel]) -> [MKPointAnnotation] {
        return points.map { point in
            let partner = partners.first(where: { point.partnerName == $0.id })
            let annotation = MKPointAnnotation()
            annotation.title = partner?.name ?? point.partnerName
            annotation.subtitle = point.fullAddress
            annotation.coordinate = point.location
            return annotation
        }
    }
}
