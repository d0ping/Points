//
//  JSONObjectDecodableProtocol.swift
//  Points
//
//  Created by Denis Bogatyrev on 03/10/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//

import Foundation

typealias JSON = Any
typealias JSONObject = [String: Any]
typealias JSONArray = [Any]

protocol JSONObjectDecodable {
    init?(jsonObject: JSONObject)
}
