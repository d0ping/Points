//
//  PointAnnotationView.swift
//  Points
//
//  Created by Denis Bogatyrev on 30/09/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//

import MapKit

typealias Closur<T> = (T) -> Void

final class PointAnnotationView: MKAnnotationView {
    var callPhoneClosure: Closur<String>?
    var openUrlClosure: Closur<URL>?
    
    private weak var calloutView: PointDetailView?
    override var annotation: MKAnnotation? {
        willSet { calloutView?.removeFromSuperview() }
        didSet { if let ann = self.annotation as? PointAnnotation { update(ann) } }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        isEnabled = true
        canShowCallout = false
    }
    
    private func update(_ annotation: PointAnnotation) {
        image = UIImage.annotationImage(with: annotation.image )
        clusteringIdentifier = annotation.partnerId
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        calloutView?.removeFromSuperview()
    }
    
    private func makeCalloutView() -> PointDetailView {
        let resultView = PointDetailView.loadFromNib()
        if let model = annotation as? PointAnnotation {
            resultView.setup(model)
            resultView.callPhoneAction = { [weak self] in
                guard let closure = self?.callPhoneClosure, let tel = model.tel else { return }
                closure(tel.digits)
            }
            resultView.openUrlAction = { [weak self] in
                guard let closure = self?.openUrlClosure, let url = model.url else { return }
                closure(url)
            }
        }
        return resultView
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            calloutView?.removeFromSuperview()
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
}

extension PointAnnotationView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event) else { return nil }
        superview?.bringSubviewToFront(self)
        return hitView
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if bounds.contains(point) { return true }
        return subviews.contains(where: { $0.frame.contains(point) })
    }
}
