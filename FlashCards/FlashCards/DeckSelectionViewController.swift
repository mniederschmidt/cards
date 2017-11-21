import UIKit

class DeckSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DeckSelectionModelDelegate {
    
    @IBOutlet weak var decksTableView: UITableView!
    var deckModel: DeckSelectionModel!
    let decksPersistence = DecksPersistence(decksURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("decks.json"))
    var firstAppearance: Bool = true
    
	override func viewDidLoad() {
		super.viewDidLoad()
        self.deckModel = DeckSelectionModel(decksPersistence, client: DeckServiceClient())
        self.deckModel.delegate = self
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.firstAppearance {
            self.animateTable()
            self.firstAppearance = false
        } 
    }

    func updateView() {
        DispatchQueue.main.async {
            self.decksTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deckModel.decks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let keyString = deckModel.decks[indexPath.row].title
        cell.textLabel?.text = keyString
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        deckModel.deckSelected(at: indexPath.row)
        performSegue(withIdentifier: "showDeck", sender: nil)
    }
    
    // Animate Table View Appearing:  Loop through all cells and set each one to the very bottom,
    //                                so it appears the list is being pulled up from the bottom of the screen,
    //                                with a spring-like effect
    func animateTable() {
        self.decksTableView.reloadData()
        
        let cells = self.decksTableView.visibleCells
        let tableHeight: CGFloat = self.decksTableView.bounds.size.height
        
        var index = 0
        
        for cell in cells {
            let cell: UITableViewCell = cell as UITableViewCell
            // render different delay for each cell; top ones come up faster
            UIView.animate(withDuration: 1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [.allowUserInteraction], animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: -tableHeight)
            }, completion: nil)
            index += 1
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let flashCardController as FlashCardViewController:
            if let deck = deckModel.deckForSelection() {
                flashCardController.model = FlashCardModel(deck: deck, persistence: decksPersistence)
            }
        default:
            break
        }
    }
    
    @IBAction func addDeck(_ sender: Any) {
        let addDeckAlert = UIAlertController(title: "Add new deck", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        let addDeckAction = UIAlertAction(title: "Add Deck", style: UIAlertActionStyle.default) { [weak addDeckAlert] _ in
            if let textFields = addDeckAlert?.textFields {
                let deckNameTextField = textFields[0]
                let deckName = deckNameTextField.text
                
                self.deckModel.addDeck(withTitle: deckName ?? "")
                self.decksTableView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
        
        addDeckAlert.addTextField { textField in
            textField.placeholder = "Deck name"
        }
        
        addDeckAlert.addAction(addDeckAction)
        addDeckAlert.addAction(cancelAction)
        
        self.present(addDeckAlert, animated: true)
    }
}




















