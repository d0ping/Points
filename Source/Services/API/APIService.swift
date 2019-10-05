//
//  APIService.swift
//  Points
//
//  Created by Denis Bogatyrev on 22/09/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//

import Foundation

enum APIRequestResult {
    case success(JSONObject)
    case failure(APIError)
}

enum APIError {
    case invalidURLError
    case httpError(Error?)
    case decodeError
    case lastModifiedError
    case filereadError
    case unknownError
}

protocol APIServiceType: class {
    func request(_ endpoint: APIEndpoint, handler: @escaping (APIRequestResult) -> Void)
}

final class APIService: APIServiceType {
    private var urlSession = URLSession(configuration: .default)
    
    func decodeJSON(data: Data) throws -> JSON {
        return try JSONSerialization.jsonObject(with: data, options: [])
    }
    
    func request(_ endpoint: APIEndpoint, handler: @escaping (APIRequestResult) -> Void) {
        guard let url = endpoint.url else {
            return handler(.failure(.invalidURLError))
        }
        
        let task = urlSession.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, let json = try? self?.decodeJSON(data: data), let jsonObject = json as? JSONObject else {
                let error = APIError.decodeError
                return handler(.failure(error))
            }
            DispatchQueue.main.async {
                handler(.success(jsonObject))
            }
        }
        task.resume()
    }
}
