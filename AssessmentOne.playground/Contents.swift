import UIKit
import Foundation

// Build a network layer
enum HTTPMethod: String {
    case delete = "DELETE"
    case get = "GET"
}

enum HTTPScheme: String {
    case http
    case https
}

protocol API {
    var scheme: HTTPScheme { get }
    var baseURL: String { get }
    var path: String { get }
    var parameters: [URLQueryItem] { get }
    var method: HTTPMethod { get }
}


final class NetworkManager {
    
    private class func buildURL(endPoint: API) -> URLComponents {
        var components = URLComponents()
        components.scheme = endPoint.scheme
        components.host = endPoint.baseURL
        components.path = endPoint.path
        components.queryItems = endPoint.httpMethod
    }
    
    class func request<T: Decodable> ( endPoint: API, completion: @escaping (Result<T, Error>)) {
        let components = buildURL(endPoint: endPoint)
        guard let url = components.url else {
            Log.error("URL creation error")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endPoint.method.rawValue
        
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: urlRequest) {
            data, response, error in
            if let error = error {
                completion(.failure(error))
                Log.error("Unknown error", error)
                return
            }
            
            guard response != nil, let data = data else {
                return
            }
            
            let responseObject = try ? JSONDecoder().decode(T.self, from: data) {
                completion(.success(responseObject))
            } else {
                let error = NSError(domain: "com.soething", code: 200, userInfo: [NSLocalizedDescriptionKey: "Failed"])
                completion(.failure(error))
            }
        }
        dataTask.resume()        
    }
}


