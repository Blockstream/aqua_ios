import Foundation
import UIKit

class SupportViewController: BaseViewController {

    enum Voices: CaseIterable {
        case support
        case rate
        case updates
    }

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = NSLocalizedString("id_support_and_feedback", comment: "")
    }

    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self

        let footerView = Bundle.main.loadNibNamed("SupportFooterCell", owner: self, options: nil)![0] as? SupportFooterCell
        footerView?.configure()
        tableView.tableFooterView = footerView
    }
}

extension SupportViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Voices.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.accessoryType = .disclosureIndicator
        switch Voices.allCases[indexPath.row] {
        case .support:
            cell?.textLabel?.text = NSLocalizedString("id_support_and_faqs", comment: "")
        case .rate:
            cell?.textLabel?.text = NSLocalizedString("id_rate_the_app", comment: "")
        case .updates:
            cell?.textLabel?.text = NSLocalizedString("id_check_updates", comment: "")
            cell?.accessoryView = UIImageView.init(image: UIImage(named: "external_link"))
        }
        return cell ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Voices.allCases[indexPath.row] {
        case .support:
            break
        case .rate:
            break
        case .updates:
            break
        }
    }
}
