//
//  ImageProvider.swift
//  Points
//
//  Created by Denis Bogatyrev on 03/10/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//

import UIKit

protocol ImageProviderType: class {
    func obtainImage(with name: String, partnerId: String, completion: @escaping (UIImage?) -> Void)
}

final class ImageProvider: ImageProviderType {
    private let loader: ImageLoaderServiceType
    private let storage: StorageServiceType
    private let urlBuilder: ImageURLBuilderType
    
    init(loader: ImageLoaderServiceType, storage: StorageServiceType, urlBuilder: ImageURLBuilderType) {
        self.loader = loader
        self.storage = storage
        self.urlBuilder = urlBuilder
    }
    
    func obtainImage(with name: String, partnerId: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = urlBuilder.imageURL(with: name) else {
            completion(nil)
            return
        }
        
        let model = storage.fetchImage(at: url.absoluteString.md5)
        loader.loadImage(at: url, lastModified: model?.lastModified) { [weak self] result in
            switch result {
            case .success(let image):
                DispatchQueue.global(qos: .userInitiated).async {
                    let annotationImage = UIImage.annotationImage(with: image)
                    self?.storage.saveImage(image, annotationImage: annotationImage, with: url.absoluteString.md5, partnerId: partnerId)
                    DispatchQueue.main.async {
                        completion(image)
                    }
                }
            case .failure(let error):
                if case .lastModifiedError = error { print("Image: /(name) not modified") }
                completion (model?.image)
            }
        }
    }
}
