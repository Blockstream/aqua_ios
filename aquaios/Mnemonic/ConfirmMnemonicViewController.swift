import UIKit

class ConfirmMnemonicViewController: BaseViewController {

    @IBOutlet weak var confirmTitle: UILabel!
    @IBOutlet var confirmationLabels: [UILabel]!
    @IBOutlet var confirmationButtons: [UIButton]!
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet var firstRowButtons: [UIButton]!
    @IBOutlet var secondRowButtons: [UIButton]!
    @IBOutlet var thirdRowButtons: [UIButton]!
    @IBOutlet var fourthRowButtons: [UIButton]!

    private var mnemonic: [Substring] {
        get {
            guard let mnemonic = try? Bitcoin.shared.session?.getMnemonicPassphrase(password: "") else {
                return []
            }
            return mnemonic.split(separator: " ")
        }
    }

    private var quiz = [Int]()
    private var score = [Int](repeating: 0, count: 4)

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        quiz = generateQuiz()
        var buttonsWords = [String]()
        for i in 0..<4 {
            buttonsWords.append(contentsOf: generateButtonRowWords(answerIndex: quiz[i]))
            confirmationLabels[i].text = String(format: NSLocalizedString("id_select_word_d", comment: ""), quiz[i]+1)
        }
        for i in 0..<confirmationButtons.count {
            confirmationButtons[i].round(radius: 18)
            confirmationButtons[i].setTitle(buttonsWords[i], for: .normal)
        }
        confirmTitle.text = NSLocalizedString("id_confirm_backup", comment: "")
        completeButton.round(radius: 24)
        completeButton.setTitle(NSLocalizedString("id_complete", comment: ""), for: .normal)
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
        let selectedWord = selected.titleLabel?.text ?? ""
        if selectedWord == String(mnemonic[quiz[position]]) {
            score[position] = 1
        } else {
            score[position] = 0
        }
    }

    func generateQuiz() -> [Int] {
        var indeces: [Int] = [Int](repeating: 0, count: 4)
        repeat {
            indeces = indeces.map { (_) -> Int in getIndexFromUniformUInt32(count: 11) }
        } while Set(indeces).count != 4
        return indeces
    }
    func generateButtonRowWords(answerIndex: Int) -> [String] {
        var words: [String] = [String]()
        var wordNumbers = [Int]()
        wordNumbers.append(answerIndex)
        while Set(wordNumbers).count != 3 {
            let index = getIndexFromUniformUInt32(count: 11)
            if !wordNumbers.contains(index) { wordNumbers.append(index) }
        }
        for i in wordNumbers {
            words.append(String(mnemonic[i]))
        }
        return words.shuffled()
    }

    func getIndexFromUniformUInt32(count: Int) -> Int {
        return Int(try! getUniformUInt32(upper_bound: UInt32(count)))
    }

    func isComplete() -> Bool {
        let sum = score.reduce(0, {$0 + $1})
        return sum == 4
    }

    @IBAction func completeButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "complete", sender: nil)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? BackupCompleteViewController {
            dest.success = isComplete()
        }
    }
}
