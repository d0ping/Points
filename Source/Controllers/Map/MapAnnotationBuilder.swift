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
    func buildAnnotations(at points: [PointModel], partners: [PartnerModel]) -> [PointAnnotation]
}

class MapAnnotationBuilder: MapAnnotationBuilderType {
    func buildAnnotations(at points: [PointModel], partners: [PartnerModel]) -> [PointAnnotation] {
        return points.map { point in
            let partner = partners.first(where: { point.partnerName == $0.id })
            
            return PointAnnotation(coordinate: point.location,
                                   partnerId: point.partnerName,
                                   title: partner?.name ?? point.partnerName,
                                   subtitle: point.fullAddress,
                                   annotationImage: partner?.image?.annotationImage,
                                   image: partner?.image?.image,
                                   fullAddress: point.fullAddress,
                                   workHours: point.workHours,
                                   url: partner?.url,
                                   tel: point.phones)
        }
    }
}
