import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import Foundation

let server = HTTPServer()
server.serverName = "localhost"
server.serverPort = 8080
server.addRoutes(Router().routes())

try! server.start()
