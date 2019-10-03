//
//  APIConfiguration.swift
//  Points
//
//  Created by Denis Bogatyrev on 23/09/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//

import Foundation

struct APIConfiguration {
    var scheme: String { return "https" }
    var baseHost: String { return "api.tinkoff.ru" }
    var resourceHost: String { return "static.tinkoff.ru" }
}
