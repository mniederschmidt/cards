import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import Foundation

class RouteHandler {
    
    let persistence: DecksPersistence
    
    init(persistence: DecksPersistence) {
        self.persistence = persistence
    }
    
    func handleGET(response: HTTPResponse) {
        response.setHeader(.contentType, value: "application/json")
        response.status = .ok
        
        if let data = try? JSONEncoder().encode(persistence.readDecks()) {
            let bytes = [UInt8](data)
            response.appendBody(bytes: bytes)
        }
        
        response.completed()
    }
    
    func handlePOST(request: HTTPRequest, response: HTTPResponse) {
        response.setHeader(.contentType, value: "application/json")
        
        guard let body = request.postBodyString,
            let attempt = try? body.jsonDecode() as? [String:Any],
            let requestJson = attempt else {
                response.status = .badRequest
                response.setBody(string: "Invalid Body. Was unable to parse the JSON")
                response.completed()
                return
        }
        
        response.status = .ok
        
        if let data = try? JSONEncoder().encode(persistence.readDecks()) {
            let bytes = [UInt8](data)
            response.appendBody(bytes: bytes)
        }
        
        response.completed()
    }
}
