import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import Foundation

class Router {
    
    private let handler: RouteHandler
    
    init(_ handler: RouteHandler) {
        self.handler = handler
    }
    
    func routes() -> Routes {
        var routes = Routes()
        routes.add([routeForGetDecks()])
        routes.add([routeForPostDecks()])
        return routes
    }
    
    private func routeForGetDecks() -> Route {
        let route = Route(method: .get, uri: "/decks") { (_, response) in
            self.handler.handleGET(response: response)
        }
        return route
    }
    
    private func routeForPostDecks() -> Route {
        let route = Route(method: .post, uri: "/decks") { (request, response) in
            self.handler.handlePOST(request: request, response: response)
        }
        return route
    }
}
