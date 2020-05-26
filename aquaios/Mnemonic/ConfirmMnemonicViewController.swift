import UIKit

class ConfirmMnemonicViewController: BaseViewController {

    @IBOutlet var confirmationLabels: [UILabel]!
    @IBOutlet var confirmationButtons: [UIButton]!
    @IBOutlet var completeButton: UIView!

    @IBOutlet var firstRowButtons: [UIButton]!
    @IBOutlet var secondRowButtons: [UIButton]!
    @IBOutlet var thirdRowButtons: [UIButton]!
    @IBOutlet var fourthRowButtons: [UIButton]!

    private var mnemonic: [Substring] {
        get {
            if let mnemonic = UserDefaults.standard.object(forKey: Constants.Keys.mnemonic) as? String {
                return mnemonic.split(separator: " ")
            }
            return []
        }
    }

    private var selectedWords = [String?](repeating: nil, count: 4)
    private var expectedWords = [String?](repeating: nil, count: 4)

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        confirmationButtons.forEach { (button) in
            button.round(radius: 18)
        }
        completeButton.round(radius: 24)
        expectedWords = generateRandomWords()
    }

    @IBAction func firstRowSelect(_ sender: UIButton) {
        updateSelected(for: firstRowButtons, selected: sender, position: 0)
    }

    @IBAction func secondRowSelect(_ sender: UIButton) {
        updateSelected(for: secondRowButtons, selected: sender, position: 1)
    }

    @IBAction func thirdRowSelect(_ sender: UIButton) {
        updateSelected(for: thirdRowButtons, selected: sender, position: 2)
    }

    @IBAction func fourthRowSelect(_ sender: UIButton) {
        updateSelected(for: fourthRowButtons, selected: sender, position: 3)
    }

    private func updateSelected(for buttons: [UIButton], selected: UIButton, position: Int) {
        buttons.forEach { (button) in
            button.backgroundColor = .lighterBlueGray
        }
        selected.backgroundColor = .teal
        selectedWords[position] = selected.titleLabel?.text ?? ""
    }

    func generateRandomWords() -> [String] {
        var wordNumbers: [Int] = [Int](repeating: 0, count: 4)
        repeat {
            wordNumbers = wordNumbers.map { (_) -> Int in getIndexFromUniformUInt32(count: 11) }
        } while Set(wordNumbers).count != 4
        var words: [String] = [String](repeating: "", count: 4)
        for i in wordNumbers {
            words.append(String(mnemonic[i]))
        }
        return words
    }

    func getIndexFromUniformUInt32(count: Int) -> Int {
        return Int(try! getUniformUInt32(upper_bound: UInt32(count)))
    }

    @IBAction func completeButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "complete", sender: nil)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? BackupCompleteViewController {
            dest.success = true
        }
    }
}
