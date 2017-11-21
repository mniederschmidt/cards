import UIKit

enum FlipSide {
    case front, back
}

class FlashCardViewController: UIViewController {
    
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var flipImageView: UIImageView!
    @IBOutlet private weak var flipView: UIView!
    @IBOutlet private weak var flipViewTextLabel: UILabel!
    @IBOutlet private weak var deckTableView: UITableView!
    @IBOutlet weak var cameraButton: UIButton!
    
    var model: FlashCardModel?
    fileprivate var currentVisibleSide = FlipSide.front
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deckTableView.delegate = self
        deckTableView.dataSource = self
        populateCardFields(withSide: .front)
    }
    
    func populateCardFields(withSide side: FlipSide) -> Void {

        currentVisibleSide = side

        if side == .front {
            flipViewTextLabel.text = model?.getCurrentCard()?.front
        } else {
            flipViewTextLabel.text = model?.getCurrentCard()?.back
        }
        
        guard let image = model?.getCurrentCardImage(withSide: side) else { flipImageView.isHidden = true; return }
        flipImageView.isHidden = false
        
        flipImageView.image = image
    }
}

//MARK: - IBActions
extension FlashCardViewController {
    
    @IBAction func setImage(_ sender: Any) {
        
        // Animation to make button slightly bigger when button is pressed
        UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
            self.cameraButton.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
        }) { (completed:Bool) in
            self.cameraButton.transform = CGAffineTransform.identity
        }
        
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("can't open photo library")
            return
        }
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        present(imagePicker, animated: true)
    }
    
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
                self.populateCardFields(withSide: .front)
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
        populateCardFields(withSide: .front)
    }
    
    @IBAction func selectNextCard(_ sender: UIButton) {
        model?.moveToNext()
        populateCardFields(withSide: .front)
    }
    
    @IBAction func flipItButtonPressed(_ sender: UIButton) {
        let animationOptions: UIViewAnimationOptions
        // Different Animations for Card Flip:  Flip from Left or Right, Curl Down, Cross Dissolve
//        if self.currentVisibleSide == .front {
//            animationOptions = [.curveEaseInOut, .transitionFlipFromLeft]
//        } else {
//            animationOptions = [.curveEaseInOut, .transitionFlipFromRight]
//        }
//        animationOptions = [.transitionCurlDown]
        animationOptions = [.transitionCrossDissolve]

        UIView.transition(with: flipView, duration: 1.0, options: animationOptions, animations: {
            if self.currentVisibleSide == .front {
                self.currentVisibleSide = .back
            } else {
                self.currentVisibleSide = .front
            }
            self.populateCardFields(withSide: self.currentVisibleSide)

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
        populateCardFields(withSide: .front)
    }
}
// MARK: - UIImagePickerControllerDelegate
extension FlashCardViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        defer {
            picker.dismiss(animated: true)
        }
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage,
              let imageData = UIImagePNGRepresentation(image) else {
            return
        }
        
        model?.updateCurrentCard(withImageData: imageData, withSide: self.currentVisibleSide)
        // Needed next line to fix bug with image initially not showing after being added
        flipImageView.isHidden = false
        flipImageView.image = image
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        defer {
            picker.dismiss(animated: true)
        }
    }
    
}
