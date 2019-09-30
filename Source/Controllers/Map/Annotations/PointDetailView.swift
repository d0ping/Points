//
//  PointDetailView.swift
//  Points
//
//  Created by Denis Bogatyrev on 01/10/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//

import UIKit

class PointDetailView: UIView {
    
    @IBOutlet weak var logoImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addresLabel: UILabel!
    @IBOutlet weak var workHoursLabel: UILabel!
    
    @IBOutlet weak var urlButton: UIButton!
    @IBOutlet weak var telButton: UIButton!

    class func loadFromNib() -> PointDetailView {
        let nib  = UINib.init(nibName: "PointDetailView", bundle: nil)
        let nibObjects = nib.instantiate(withOwner: self, options: nil)
        return nibObjects.first(where: { $0 is PointDetailView }) as! PointDetailView
    }
    
    func setup(_ annotation: PointAnnotation) {
        logoImageView.image = annotation.image
        
        titleLabel.text = annotation.title
        addresLabel.text = annotation.fullAddress
        workHoursLabel.text = "Рабочие часы:\n\(annotation.workHours ?? "")"
        
        urlButton.isHidden = annotation.url == nil
        telButton.isHidden = annotation.tel == nil
    }
}
