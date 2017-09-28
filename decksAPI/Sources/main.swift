import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import Foundation

let routeHandler: RouteHandler = {
    let urlToDatabase = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("decks.json")
    let persistence = DecksPersistence(decksURL: urlToDatabase)
    return RouteHandler(persistence)
}()

let server = HTTPServer()
server.serverName = "localhost"
server.serverPort = 8080
server.addRoutes(Router(routeHandler).routes())

try! server.start()


