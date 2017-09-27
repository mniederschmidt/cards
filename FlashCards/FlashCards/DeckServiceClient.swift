import Foundation

typealias GetDecksCompletion = (_ result: GetDecksResult) -> Void
typealias PostDecksCompletion = (_ result: PostDecksResult) -> Void

struct GetDecksResult {
    let decks: [Deck]?
    let error: ServiceError?
}

struct PostDecksResult {
    let success: Bool
}

class DeckServiceClient: ServiceClient {
    let url = URL(string: "http://localhost:8080/decks")!
    
    func getDecks(completion: @escaping GetDecksCompletion) {
        
        request(url, method: .GET) { (result) in
            guard result.error == nil else {
                completion(GetDecksResult(decks: nil, error: result.error!))
                return
            }
            guard let data = result.data,
                let decks = try? JSONDecoder().decode([Deck].self, from: data) else {
                    completion(GetDecksResult(decks: nil, error: .jsonParseError))
                    return
            }
            completion(GetDecksResult(decks: decks, error: nil))
        }
    }
    
    func post(_ decks: [Deck], completion: @escaping PostDecksCompletion) {

    }
}
