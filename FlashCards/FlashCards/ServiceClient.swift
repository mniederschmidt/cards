import Foundation

// For Swift Documentation: http://nshipster.com/swift-documentation/

typealias ServiceCompletion = (_ result: ServiceResult) -> Void

struct ServiceResult {
    let data: Data?
    let error: ServiceError?
}

enum ServiceError: Error {
    
    case internalServiceError
    case jsonParseError
    
    var description: String {
        switch self {
        case .internalServiceError:
            return "service error!"
        case .jsonParseError:
            return "couldn't read decks from server!"
        }
    }
}

enum ServiceMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

class ServiceClient {
    
    /**
     Send request without a body.
     */
    
    func request(_ url:URL, method: ServiceMethod, completion: @escaping ServiceCompletion) {
        let request = buildRequest(url, method: method)
        makeServiceCall(request, completion: completion)
    }
    
    /**
     Send request with a body.
     - Returns: false if body fails to encode
     */
    
    func request(_ url:URL, method: ServiceMethod, body:[String:Codable], completion: @escaping ServiceCompletion) -> Bool {
        guard let data = try? JSONEncoder().encode(body) else {
            return false
        }
        let request = buildRequest(url, method: method, data: data)
        makeServiceCall(request, completion: completion)
        return true
    }
    
    // MARK: - Private Methods
    
    private func buildRequest(_ url:URL, method: ServiceMethod, data: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        
        if let data = data {
            request.httpBody = data
        }
        
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let method = request.httpMethod, let url = request.url {
            print("🌎[\(method) REQUEST] \(url)")
        }
        return request
    }
    
    private func makeServiceCall( _ request: URLRequest, completion: @escaping ServiceCompletion) {
        
        let completionHandler = { [weak self]
            (data: Data?, response: URLResponse?, error: Error?) in
            guard let weakSelf = self else {
                return
            }
            weakSelf.handleResponse(data, response, error, completion: completion)
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    private func handleResponse(_ data: Data?, _ response: URLResponse?, _ error: Error?, completion: ServiceCompletion) {
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
            completion(ServiceResult(data: nil, error: .internalServiceError))
            return
        }
        
        print("🌎[RESPONSE CODE] \(statusCode)")
        
        guard 200 ... 299 ~= statusCode else {
            completion(ServiceResult(data: nil, error: .internalServiceError))
            return
        }
        
        guard error == nil else {
            completion(ServiceResult(data: nil, error: .internalServiceError))
            return
        }
        
        completion(ServiceResult(data: data!, error: nil))
    }
}
