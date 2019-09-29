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

typealias JSON = Any
typealias JSONObject = [String: Any]
typealias JSONArray = [Any]

protocol JSONObjectDecodable {
    init?(jsonObject: JSONObject)
}

protocol APIResult: JSONObjectDecodable {}

enum APIError {
    case clientError(Error?)
    case decodeError
    case invalidURLError
    case unknownError
}



protocol APIServiceType: class {
    func request(_ endpoint: APIEndpoint, handler: @escaping (APIRequestResult) -> Void)
}

final class APIService: APIServiceType {
    private let config: APIServiceConfigurationType
    
    private var urlSession = URLSession(configuration: .default)
    
    init(config: APIServiceConfigurationType) {
        self.config = config
    }
    
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
