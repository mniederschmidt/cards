import Foundation

class DecksPersistence {
    
    fileprivate let decksURL: URL
    
    init(decksURL: URL) {
        self.decksURL = decksURL
        // Save Initial Data to database
        if readDecks().isEmpty {
            save(initialDecks)
        }
    }
    
    func readDecks() -> [Deck] {
        print("🤠 Reading decks from: \(decksURL.path)")
        guard let data = try? Data(contentsOf: decksURL),
            let decks = try? JSONDecoder().decode([Deck].self, from: data) else {
            return []
        }
        return decks
    }
    
    func createOrUpdate(_ decks: [Deck]) {
        var decksFromFile = readDecks()
        
        for deckToSave in decks {
            if let matchedDeck = decksFromFile.first(where: { return $0 == deckToSave }) {
                matchedDeck.cards = deckToSave.cards
                matchedDeck.title = deckToSave.title
            } else {
                decksFromFile.append(deckToSave)
            }
        }
        
        save(decksFromFile)
    }
}
//MARK: - Private Helpers
extension DecksPersistence {
    @discardableResult
    fileprivate func save(_ decks: [Deck]) -> Bool {
        let encoder = JSONEncoder()
//        encoder.outputFormatting = .prettyPrinted
        print("🤠 Trying to store decks at: \(decksURL.path)")
        
        guard let data = try? encoder.encode(decks), let _ = try? data.write(to: decksURL) else {
            print("🔴 Failed to write to disk")
            return false
        }
        print("✅ Save successful")
        return true
    }
    
    fileprivate var initialDecks: [Deck] {
        let cityCards = [
            Card(front: "Illinois", back: "Springfield", id: UUID()),
            Card(front: "Nebraska", back: "Lincoln", id: UUID()),
            Card(front: "New York", back: "Albany", id: UUID()),
            Card(front: "Missouri", back: "Jefferson City", id: UUID()),
            Card(front: "Kansas", back: "Topeka", id: UUID())
        ]
        let cityId = UUID(uuidString: "47A65B55-9C56-413A-BCC8-08E3BFB52BFD")!
        let cityDeck = Deck("State Capitals", cards: cityCards, id: cityId)
        
        let baseballCards = [
            Card(front: "Baltimore", back: "Orioles", id: UUID()),
            Card(front: "Chicago", back: "Cubs", id: UUID()),
            Card(front: "St. Louis", back: "Cardinals", id: UUID()),
            Card(front: "Boston", back: "Red Sox", id: UUID()),
            Card(front: "New York", back: "Yankees", id: UUID())
        ]
        let baseballId = UUID(uuidString: "387EB87C-10B6-4DEA-A0B5-B77C584B2580")!
        let baseballDeck = Deck("Baseball", cards: baseballCards, id: baseballId)
        
        return [cityDeck, baseballDeck]
    }
}
