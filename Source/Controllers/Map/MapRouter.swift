//
//  MapRouter.swift
//  Points
//
//  Created by Denis Bogatyrev on 01/10/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//

import UIKit

protocol MapRouterType: class {
    func callPhone(_ tel: String)
    func openWebSite(_ url: URL)
}

final class MapRouter: MapRouterType {
    func callPhone(_ tel: String) {
        if let url = URL(string: "telprompt://\(tel)"), UIApplication.shared.canOpenURL(url) {
            openUrl(url)
        }
    }
    
    func openWebSite(_ url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            openUrl(url)
        }
    }
    
    private func openUrl(_ url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
