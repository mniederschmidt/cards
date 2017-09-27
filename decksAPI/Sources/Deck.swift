import Foundation

class Deck: Codable, Equatable {
    var cards: [Card]
    var title: String
    let id: UUID
    init(_ title: String, cards: [Card] = [], id: UUID) {
        self.cards = cards
        self.title = title
        self.id = id
    }
    static func==(lhs:Deck, rhs: Deck) -> Bool {
        return lhs.id == rhs.id
    }
}
