//
//  ImageExtension.swift
//  Points
//
//  Created by Denis Bogatyrev on 05/10/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//

import UIKit

extension UIImage {
    private static var defaultAnnotationImage: UIImage { return UIImage(named: "map_pin") ?? UIImage() }
    
    static func annotationImage(with extraImage: UIImage? = nil) -> UIImage {
        guard let image = extraImage else { return defaultAnnotationImage }
        let size = CGSize(width: 40, height: 40)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            ctx.cgContext.setFillColor(UIColor.gray.cgColor)
            ctx.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
            
            ctx.cgContext.setFillColor(UIColor.white.cgColor)
            ctx.cgContext.fillEllipse(in: CGRect(origin: CGPoint(x: size.width * 0.01, y: size.height * 0.01),
                                                 size: CGSize(width: size.width * 0.98, height: size.height * 0.98)))
            
            image.circleMasked().draw(in: CGRect(origin: CGPoint(x: size.width * 0.04, y: size.height * 0.04),
                                  size: CGSize(width: size.width * 0.92, height: size.height * 0.92)))
        }
    }
    
    private func circleMasked() -> UIImage {
        let canvas = min(size.width, size.height)
        let canvasSize = CGSize(width: canvas, height: canvas)
        let canvasRect = CGRect(origin: .zero, size: canvasSize)
        
        return UIGraphicsImageRenderer(size: size).image { ctx in
            let cgImage = self.cgImage?.cropping(to: CGRect(origin: CGPoint(x: size.width > size.height ? floor((size.width - size.height) / 2) : 0,
                                                                       y: size.height > size.width  ? floor((size.height - size.width) / 2) : 0),
                                                       size: canvasSize))
            UIBezierPath(ovalIn: canvasRect).addClip()
            UIImage(cgImage: cgImage!, scale: 1, orientation: imageOrientation).draw(in: canvasRect)
        }
    }
}
