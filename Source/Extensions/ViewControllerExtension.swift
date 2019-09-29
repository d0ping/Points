//
//  ViewControllerExtension.swift
//  Points
//
//  Created by Denis Bogatyrev on 24/09/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//

import UIKit

extension UIViewController {
    var screenFactory: AppScreenFactoryType { return AppProvider.shared.screenFactory }
}
