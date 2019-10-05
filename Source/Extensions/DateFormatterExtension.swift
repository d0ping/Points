//
//  DateFormatterExtension.swift
//  Points
//
//  Created by Denis Bogatyrev on 03/10/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//

import Foundation

extension DateFormatter {
    static func apiDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "EEE, dd LLL yyyy HH:mm:ss zzz"
        return dateFormatter
    }
}
