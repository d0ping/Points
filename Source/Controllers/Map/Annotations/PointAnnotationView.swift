//
//  PointAnnotationView.swift
//  Points
//
//  Created by Denis Bogatyrev on 30/09/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//

import MapKit

class PointAnnotationView: MKAnnotationView {
    weak var calloutView: PointDetailView?
    override var annotation: MKAnnotation? {
        willSet { calloutView?.removeFromSuperview() }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        canShowCallout = false
        image = UIImage(named: "map_pin")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.calloutView?.removeFromSuperview()
    }
    
    private func makeCalloutView() -> PointDetailView {
        let resultView = PointDetailView.loadFromNib()
        if let model = annotation as? PointAnnotation {
            resultView.setup(model)
        }
        return resultView
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.calloutView?.removeFromSuperview()            
            let pointCalloutView = makeCalloutView()
            
            pointCalloutView.frame.origin.x -= pointCalloutView.frame.width / 2 - frame.width / 2
            pointCalloutView.frame.origin.y -= pointCalloutView.frame.height
            
            addSubview(pointCalloutView)
            calloutView = pointCalloutView
            
            if animated {
                calloutView!.alpha = 0.0
                UIView.animate(withDuration: 0.3, animations: {
                    self.calloutView!.alpha = 1.0
                })
            }
        } else {
            guard let calloutView = calloutView else { return }
            if animated {
                UIView.animate(withDuration: 0.3, animations: {
                    calloutView.alpha = 0.0
                }, completion: { (success) in
                    calloutView.removeFromSuperview()
                })
            } else {
                calloutView.removeFromSuperview()
            }
        }
        
    }
    
//    @objc func callPhoneNumber(sender: UIButton) {
//        let v = sender.superview as! CustomCalloutView
//        if let url = URL(string: "telprompt://\(v.starbucksPhone.text!)"), UIApplication.shared.canOpenURL(url)
//        {
//            UIApplication.shared.openURL(url)
//        }
//    }
}
