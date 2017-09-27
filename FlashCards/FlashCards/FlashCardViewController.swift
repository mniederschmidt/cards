import UIKit

enum FlipSide {
    case front, back
}

class FlashCardViewController: UIViewController {
    
    @IBOutlet private weak var flipView: UIView!
    @IBOutlet private weak var flipViewTextLabel: UILabel!
    @IBOutlet private weak var deckTableView: UITableView!
    
    var model: FlashCardModel?
    fileprivate var currentVisibleSide = FlipSide.front
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deckTableView.delegate = self
        deckTableView.dataSource = self
        flipViewTextLabel.text = model?.getCurrentCard()?.front
    }
}
//MARK: - IBActions
extension FlashCardViewController {
    @IBAction func addCardToDeck(_ sender: Any) {
        let addDeckAlert = UIAlertController(title: "Add new Card", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        let addDeckAction = UIAlertAction(title: "Add Card", style: UIAlertActionStyle.default) { [weak addDeckAlert] _ in
            if let textFields = addDeckAlert?.textFields {
                let frontTextField = textFields[0]
                let front = frontTextField.text
                
                let backTextField = textFields[1]
                let back = backTextField.text
                
                self.model?.addCardToDeck(withFront: front ?? "", withBack: back ?? "")
                self.deckTableView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
        
        addDeckAlert.addTextField { textField in
            textField.placeholder = "Card front"
        }
        
        addDeckAlert.addTextField { textField in
            textField.placeholder = "Card back"
        }
        
        addDeckAlert.addAction(addDeckAction)
        addDeckAlert.addAction(cancelAction)
        
        self.present(addDeckAlert, animated: true)
    }
    
    @IBAction func selectPreviousCard(_ sender: UIButton) {
        model?.moveToPrevious()
        flipViewTextLabel.text = model?.getCurrentCard()?.front
        currentVisibleSide = FlipSide.front
    }
    
    @IBAction func selectNextCard(_ sender: UIButton) {
        model?.moveToNext()
        flipViewTextLabel.text = model?.getCurrentCard()?.front
        currentVisibleSide = FlipSide.front
    }
    
    @IBAction func flipItButtonPressed(_ sender: UIButton) {
        let animationOptions: UIViewAnimationOptions
        if self.currentVisibleSide == .front {
            animationOptions = [.curveLinear, .transitionFlipFromLeft]
        } else {
            animationOptions = [.curveEaseInOut, .transitionFlipFromRight]
        }
        
        UIView.transition(with: flipView, duration: 0.5, options: animationOptions, animations: {
            if self.currentVisibleSide == .front {
                self.flipViewTextLabel.text = self.model?.getCurrentCard()?.back
                self.currentVisibleSide = .back
            } else {
                self.flipViewTextLabel.text = self.model?.getCurrentCard()?.front
                self.currentVisibleSide = .front
            }
        }) { (complete) in
            
        }
    }
}
// MARK: - UITableViewDataSource
extension FlashCardViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model?.deck.cards.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = model?.deck.cards[indexPath.row].front
        cell.detailTextLabel?.text = "???"
        
        return cell
    }
}
// MARK: - UITableViewDelegate
extension FlashCardViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        model?.selectCard(atIndex: indexPath.row)
        
        flipViewTextLabel.text = model?.getCurrentCard()?.front
        currentVisibleSide = FlipSide.front
    }
}
