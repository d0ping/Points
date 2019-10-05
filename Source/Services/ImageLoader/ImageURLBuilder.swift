//
//  ImageURLBuilder.swift
//  Points
//
//  Created by Denis Bogatyrev on 02/10/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//

import UIKit

protocol ImageURLBuilderType {
    func imageURL(with name: String) -> URL?
}

struct ImageURLBuilder: ImageURLBuilderType {
    private let configuration: APIConfiguration
    
    init(configuration: APIConfiguration) {
        self.configuration = configuration
    }
    
    private var baseURL: URL? {
        var components = URLComponents()
        components.scheme = configuration.scheme
        components.host = configuration.resourceHost
        components.path = "/icons/deposition-partners-v3"
        return components.url
    }

    private var dpiComponent: String {
        switch UIScreen.main.scale {
        case 3: return "xxhdpi"
        case 2: return "xhdpi"
        case _: return "hdpi"
        }
    }
    
    func imageURL(with name: String) -> URL? {
        guard name.isEmpty == false else { return nil }
        guard let baseURL = baseURL else { return nil }
        return baseURL.appendingPathComponent(dpiComponent).appendingPathComponent(name)
    }
}
