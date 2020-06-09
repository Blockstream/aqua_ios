import UIKit

class BuyViewController: BaseViewController {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var actionStackView: UIStackView!
    @IBOutlet weak var actionStackBackgroundView: UIView!
    @IBOutlet weak var btcButton: UIButton!
    @IBOutlet weak var lbtcButton: UIButton!

    private var wyreService: WyreService!

    override func viewDidLoad() {
        super.viewDidLoad()
        wyreService = WyreService(delegate: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        actionStackBackgroundView.round(radius: 21, borderWidth: 2, borderColor: .tiffanyBlue)
        infoLabel.text = "Checking availability..."
        wyreService.getWidget()
    }

    @IBAction func actionButtonTapped(_ sender: UIButton) {
        let buyBtc = sender.titleLabel?.text == "Buy bitcoin"
        performSegue(withIdentifier: "buy_wyre", sender: buyBtc)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? WyreWidgetViewController {
            dest.buyBtc = sender as? Bool
        }
    }
}

extension BuyViewController: WyreServiceDelegate {
    func widgetRetrieved(with widget: WyreWidget) {
        if !(widget.hasRestrictions ?? true) {
            DispatchQueue.main.async {
                self.infoLabel.text = "Buy with Debit Card"
                self.actionStackView.isHidden = false
                self.actionStackBackgroundView.isHidden = false
            }
        }
    }

    func requestFailed(with error: Error) {
    }
}
