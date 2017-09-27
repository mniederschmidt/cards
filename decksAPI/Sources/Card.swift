import Foundation

struct Card: Codable, Equatable {
    let front: String
    let back: String
    let id: UUID
    static func ==(lhs: Card, rhs: Card) -> Bool {
        return lhs.id == rhs.id
    }
}
