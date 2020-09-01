import Foundation
import UIKit

class AboutUsViewController: BaseViewController {

    enum Voices: CaseIterable {
        case twitter
        case website
    }

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = NSLocalizedString("id_about_us", comment: "")
    }

    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
    }
}

extension AboutUsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Voices.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        switch Voices.allCases[indexPath.row] {
        case .twitter:
            cell?.textLabel?.text = NSLocalizedString("id_twitter", comment: "")
            cell?.detailTextLabel?.text = "@Blockstream"
        case .website:
            cell?.textLabel?.text = NSLocalizedString("id_website", comment: "")
            cell?.detailTextLabel?.text = "blockstream.com"
        }
        return cell ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Voices.allCases[indexPath.row] {
        case .twitter:
            if let url = URL(string: "https://twitter.com/blockstream") {
              UIApplication.shared.open(url)
            }
        case .website:
            if let url = URL(string: "https://blockstream.com") {
              UIApplication.shared.open(url)
            }
        }
    }
}
