import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import Foundation

class RouteHandler {
    
    let persistence: DecksPersistence
    
    init(_ persistence: DecksPersistence) {
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
        // TODO: Get this to work
        guard let bytes = request.postBodyBytes,
            let decks = try? JSONDecoder().decode([Deck].self, from: Data(bytes: bytes)) else {
                response.setHeader(.contentType, value: "application/json")
                response.status = .badRequest
                try! response.setBody(json: ["failureMessage":"Invalid Body. Was unable to parse the JSON"])
                response.completed()
                return
        }
        
        response.status = .ok
        response.completed()
    }
}
