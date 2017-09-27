import Foundation

protocol DeckSelectionModelDelegate: class {
    func updateView()
}

class DeckSelectionModel {
    
    weak var delegate: DeckSelectionModelDelegate?
    private(set) var decks: [Deck]
    private var selectedIndex = 0
    private let persistence: DecksPersistence
    private let client: DeckServiceClient

    init(_ decksPersistence: DecksPersistence, client: DeckServiceClient) {
        self.persistence = decksPersistence
        self.decks = decksPersistence.readDecks()
        self.client = client
        
        client.getDecks { [weak self] (result) in
            guard let weakSelf = self, let decksFromServer = result.decks, !decksFromServer.isEmpty else {
                return
            }
            weakSelf.persistence.createOrUpdate(decksFromServer)
            weakSelf.decks = weakSelf.persistence.readDecks()
            weakSelf.delegate?.updateView()
        }
    }
    
    func addDeck(withTitle title: String) {
        let id = UUID()
        let newDeck = Deck(title, id: id)
        decks.append(newDeck)
        //TODO: Handle save failure (notify user)
        let _ = persistence.createOrUpdate([newDeck])
    }
    
    func deckSelected(at index: Int) {
        selectedIndex = index
    }
    
    func deckForSelection() -> Deck? {
        guard !decks.isEmpty &&
            selectedIndex <= decks.count - 1  else {
                return nil
        }
        return decks[selectedIndex]
    }
    
}
