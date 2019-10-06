//
//  ImagePreparer.swift
//  Points
//
//  Created by Denis Bogatyrev on 03/10/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//

import UIKit

protocol ImagePreparerType: class {
    func prepareImages(for partners:[PartnerModel], completion: @escaping () -> Void)
}

final class ImagePreparer: ImagePreparerType {
    private let loader: ImageLoaderServiceType
    private let storage: StorageServiceType
    private let urlBuilder: ImageURLBuilderType
    
    init(loader: ImageLoaderServiceType, storage: StorageServiceType, urlBuilder: ImageURLBuilderType) {
        self.loader = loader
        self.storage = storage
        self.urlBuilder = urlBuilder
    }
    
    func prepareImages(for partners:[PartnerModel], completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let loadGroup = DispatchGroup()
            partners.forEach { [weak self] partner in
                loadGroup.enter()
                self?.updateAndStoreImageIfNeeded(for: partner) {
                    loadGroup.leave()
                }
            }
            loadGroup.wait()
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    private func updateAndStoreImageIfNeeded(for partner: PartnerModel, completion: @escaping () -> Void) {
        guard let url = urlBuilder.imageURL(with: partner.name) else {
            completion()
            return
        }
        
        let model = storage.fetchImage(at: url.absoluteString.md5)
        loader.loadImage(at: url, lastModified: model?.lastModified) { [weak self] result in
            switch result {
            case .success(let image):
                DispatchQueue.global(qos: .userInitiated).async {
                    let annotationImage = UIImage.annotationImage(with: image)
                    self?.storage.saveImage(image, annotationImage: annotationImage, with: url.absoluteString.md5, partnerId: partner.id)
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            case .failure(let error):
                if case .lastModifiedError = error { print("Image: /(name) not modified") }
                completion ()
            }
        }
    }
}
