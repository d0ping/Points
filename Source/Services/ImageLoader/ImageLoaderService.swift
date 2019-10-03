//
//  ImageLoaderService.swift
//  Points
//
//  Created by Denis Bogatyrev on 02/10/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//

import UIKit

enum ImageDownloadResult {
    case success(UIImage)
    case failure(APIError)
}

protocol ImageLoaderServiceType {
    func loadImage(at url: URL, lastModified: Date?, handler: @escaping (ImageDownloadResult) -> Void)
}

class ImageLoaderService: ImageLoaderServiceType {
    private func makeURLSession(with lastModified: Date?) -> URLSession {
        guard let date = lastModified else { return URLSession(configuration: .default) }
        let dateString = DateFormatter.apiDateFormatter().string(from: date)
        
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.points.imageLoaderService")
        configuration.httpAdditionalHeaders = ["If-Modified-Since": dateString]
        return URLSession(configuration: configuration)
    }
    
    func loadImage(at url: URL, lastModified: Date?, handler: @escaping (ImageDownloadResult) -> Void) {
        let urlSession = makeURLSession(with: lastModified)
        let task = urlSession.downloadTask(with: url) { (location, response, error) in
            if let error = error {
                return handler(.failure(.httpError(error)))
            }
            guard let response = response, let location = location else { return handler(.failure(.unknownError)) }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 304 {
                    return handler(.failure(.lastModifiedError))
                }
            }
            
            do {
                guard let image = UIImage(data: try Data(contentsOf: location)) else { return handler(.failure(.filereadError)) }
                DispatchQueue.main.async {
                    handler(.success(image))
                }
            }
            catch {
                return handler(.failure(.filereadError))
            }
        }
        task.resume()
    }
}

