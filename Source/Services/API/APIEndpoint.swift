//
//  APIEndpoint.swift
//  Points
//
//  Created by Denis Bogatyrev on 24/09/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//

import Foundation

struct APIEndpoint {
    private let config = APIConfiguration()
    let path: String
    let queryItems: [URLQueryItem]
}

extension APIEndpoint {
    var url: URL? {
        var components = URLComponents()
        components.scheme = config.scheme
        components.host = config.baseHost
        components.path = path
        components.queryItems = queryItems
        return components.url
    }
}

enum PartnersAccountType: String {
    case credit = "Credit"
}

extension APIEndpoint {
    static func depositionPoints(latitude: Double, longitude: Double, radius: Int) -> APIEndpoint {
        return APIEndpoint(
            path: "/v1/deposition_points",
            queryItems: [
                URLQueryItem(name: "latitude", value: String(latitude)),
                URLQueryItem(name: "longitude", value: String(longitude)),
                URLQueryItem(name: "radius", value: String(radius))
            ]
        )
    }
    
    static func depositionPartners(accountType: PartnersAccountType) -> APIEndpoint {
        return APIEndpoint(
            path: "/v1/deposition_partners",
            queryItems: [
                URLQueryItem(name: "accountType", value: String(accountType.rawValue))
            ]
        )
    }
}
