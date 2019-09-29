//
//  APIServiceConfiguration.swift
//  Points
//
//  Created by Denis Bogatyrev on 23/09/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//

import Foundation

protocol APIServiceConfigurationType {
    func baseURL() -> URL
}

struct APIServiceConfiguration: APIServiceConfigurationType {
    private let host = "https://api.tinkoff.ru/"
    private let version = "v1/"
    
    func baseURL() -> URL {
        return NSURL(string: host)!.appendingPathComponent(version)!
    }
}
