import Foundation

class FlashCardModel {
    
    private(set) var deck: Deck
    private var currentCardIndex = 0
    private let persistence: DecksPersistence
    
    init(deck: Deck, persistence: DecksPersistence) {
        self.deck = deck
        self.persistence = persistence
    }
    
    func selectCard(atIndex index: Int) {
        currentCardIndex = index
    }
    
    func addCardToDeck(withFront front: String, withBack back: String) {
        let newCard = Card(front: front, back: back, id: UUID())
        deck.cards.append(newCard)
        persistence.createOrUpdate([deck])
    }
    
    func getCurrentCard() -> Card? {
        if deck.cards.count > 0 {
            return deck.cards[currentCardIndex]
        }
        return nil
    }
    
    func moveToNext() {
        if currentCardIndex == deck.cards.count - 1 {
            currentCardIndex = 0
        } else {
            currentCardIndex += 1
        }
    }
    
    func moveToPrevious() {
        if currentCardIndex == 0 {
            currentCardIndex = deck.cards.count - 1
        } else {
            currentCardIndex -= 1
        }
    }
}
