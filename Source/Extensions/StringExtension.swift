//
//  StringExtension.swift
//  Points
//
//  Created by Denis Bogatyrev on 02/10/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//

import Foundation

extension String {
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
}
