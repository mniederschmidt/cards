import UIKit

class DeckSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DeckSelectionModelDelegate {
    
    @IBOutlet weak var decksTableView: UITableView!
    @IBOutlet weak var gradientView: UIViewX!
    
    var deckModel: DeckSelectionModel!
    let decksPersistence = DecksPersistence(decksURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("decks.json"))
    var firstAppearance: Bool = true
    
    var currentColorArrayIndex: Int = -1
    var colorArray: [(color1: UIColor, color2: UIColor)] = []
    
	override func viewDidLoad() {
		super.viewDidLoad()
        
        self.deckModel = DeckSelectionModel(decksPersistence, client: DeckServiceClient())
        self.deckModel.delegate = self
        
        loadColorArray()
        animateBackgroundColor()
	}
    
    func loadColorArray() {
        let gradientColor1 = #colorLiteral(red: 0.6117647059, green: 0.1529411765, blue: 0.6901960784, alpha: 1)
        let gradientColor2 = #colorLiteral(red: 1, green: 0.2509803922, blue: 0.5058823529, alpha: 1)
        let gradientColor3 = #colorLiteral(red: 0.4823529412, green: 0.1215686275, blue: 0.6352941176, alpha: 1)
        let gradientColor4 = #colorLiteral(red: 0.1254901961, green: 0.2980392157, blue: 1, alpha: 1)
        let gradientColor5 = #colorLiteral(red: 0.1254901961, green: 0.6196078431, blue: 1, alpha: 1)
        let gradientColor6 = #colorLiteral(red: 0.3529411765, green: 0.4705882353, blue: 0.4980392157, alpha: 1)
        let gradientColor7 = #colorLiteral(red: 0.2274509804, green: 1, blue: 0.8509803922, alpha: 1)
        colorArray.append((color1: gradientColor1, color2: gradientColor2))
        colorArray.append((color1: gradientColor2, color2: gradientColor3))
        colorArray.append((color1: gradientColor3, color2: gradientColor4))
        colorArray.append((color1: gradientColor4, color2: gradientColor5))
        colorArray.append((color1: gradientColor5, color2: gradientColor6))
        colorArray.append((color1: gradientColor6, color2: gradientColor7))
        colorArray.append((color1: gradientColor7, color2: gradientColor1))
    }
    
    func animateBackgroundColor() {
        currentColorArrayIndex = currentColorArrayIndex == (colorArray.count - 1) ? 0 : currentColorArrayIndex + 1
        
        UIView.transition(with: gradientView, duration: 2, options: [.transitionCrossDissolve], animations: {
            self.gradientView.firstColor = self.colorArray[self.currentColorArrayIndex].color1
            self.gradientView.secondColor = self.colorArray[self.currentColorArrayIndex].color2
            self.gradientView.horizontalGradient = true
        }) { (success) in
            // completion block:  after successfully complete, make recursive call to self
            self.animateBackgroundColor()
        }
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




















