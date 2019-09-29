//
//  List.swift
//  Points
//
//  Created by Denis Bogatyrev on 26/09/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//

import Foundation

struct ListModel <Element: JSONObjectDecodable>: JSONObjectDecodable {
    let resultCode: String
    let trackingId: String
    let payload: [Element]
    
    init?(jsonObject: JSONObject) {
        guard let resultCode = jsonObject["resultCode"] as? String else { return nil }
        guard let trackingId = jsonObject["trackingId"] as? String else { return nil }
        guard let payload = jsonObject["payload"] as? JSONArray else { return nil }
        
        self.resultCode = resultCode
        self.trackingId = trackingId
        self.payload = payload.map { item in
            guard let pointJSON = item as? JSONObject else { return nil }
            return Element(jsonObject: pointJSON)
            }.compactMap { $0 }
    }
}
