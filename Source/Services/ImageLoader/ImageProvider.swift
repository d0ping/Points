//
//  ImageProvider.swift
//  Points
//
//  Created by Denis Bogatyrev on 03/10/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//

import UIKit

protocol ImageProviderType: class {
    func obtainImage(with name: String, completion: @escaping (UIImage?) -> Void)
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
    
    func obtainImage(with name: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = urlBuilder.imageURL(with: name) else {
            completion(nil)
            return
        }
        
        let model = storage.fetchImage(at: url.absoluteString.md5)
        loader.loadImage(at: url, lastModified: model?.lastModified) { [weak self] result in
            switch result {
            case .success(let image):
                self?.storage.saveImage(image, with: url.absoluteString.md5)
                completion(image)
            case .failure(let error):
                if case .lastModifiedError = error { print("Image: /(name) not modified") }
                completion (model?.image)
            }
        }
    }
}
