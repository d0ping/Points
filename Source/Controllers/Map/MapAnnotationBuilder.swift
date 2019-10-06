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
    func buildAnnotations(at points: [PointModel]) -> [PointAnnotation]
}

class MapAnnotationBuilder: MapAnnotationBuilderType {
    func buildAnnotations(at points: [PointModel]) -> [PointAnnotation] {
        return points.map { point in
            return PointAnnotation(coordinate: point.location,
                                   partnerId: point.partnerName,
                                   title: point.partner?.name ?? point.partnerName,
                                   subtitle: point.fullAddress,
                                   annotationImage: point.partner?.image?.annotationImage,
                                   image: point.partner?.image?.image,
                                   fullAddress: point.fullAddress,
                                   workHours: point.workHours,
                                   url: point.partner?.url,
                                   tel: point.phones)
        }
    }
}
