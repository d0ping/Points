//
//  AppSettingsManager.swift
//  Points
//
//  Created by Denis Bogatyrev on 06/10/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//

import Foundation

protocol AppSettingsManagerType: class {
    func setupDefaultSettings()
}

final class AppSettingsManager: AppSettingsManagerType {
    func setupDefaultSettings() {
        let cache = URLCache(memoryCapacity: 4*1024*1024, diskCapacity: 40*1024*1024, diskPath: nil)
        URLCache.shared = cache
    }
}
