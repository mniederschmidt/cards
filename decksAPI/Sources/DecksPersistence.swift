import Foundation

class DecksPersistence {
    
    fileprivate let decksURL: URL
    
    init(decksURL: URL) {
        self.decksURL = decksURL
        save(initialDecks)
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
        let pokemonCards = [
            Card(front: "Venasaur", back: "Grass Type", id: UUID()),
            Card(front: "Charizard", back: "Fire Type", id: UUID()),
            Card(front: "Pikachu", back: "Electric Type", id: UUID()),
            ]
        let id = UUID(uuidString: "47A65B55-9C56-413A-BCC8-08E3BFB52BF1")!
        let pokemonDeck = Deck("Pokemon", cards: pokemonCards, id: id)
        
        let heroCards = [
            Card(front: "Batman", back: "Bruce Wayne", id: UUID()),
            Card(front: "Superman", back: "Clark Kent", id: UUID()),
            ]
        let id2 = UUID(uuidString: "47A65B55-9C56-400A-BCC8-08E3BFB52BF1")!
        let heroDeck = Deck("Super Heroes", cards: heroCards, id: id2)
        
        return [pokemonDeck, heroDeck]
    }
}
