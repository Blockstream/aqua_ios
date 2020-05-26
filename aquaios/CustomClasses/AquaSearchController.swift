import UIKit

protocol AquaSearchDelegate: class {
    func didTapSearch()
    func didStartSearch()
    func didTapCancel()
    func didChangeSearchTet()
}

class AquaSearchController: UISearchController {

    var aquaSearchBar: AquaSearchBar!
    weak var searchDelegate: AquaSearchDelegate?

    init(searchResultsController: UIViewController!, delegate: AquaSearchDelegate) {
        super.init(searchResultsController: searchResultsController)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func configureBar(frame: CGRect, placeholder: String, font: UIFont, textColor: UIColor, tintColor: UIColor) {
        aquaSearchBar = AquaSearchBar(frame: frame, font: font, textColor: textColor)
        aquaSearchBar.placeholder = placeholder
        aquaSearchBar.font = font
        aquaSearchBar.tintColor = textColor
        aquaSearchBar.barTintColor = tintColor
        aquaSearchBar.showsBookmarkButton = false
        aquaSearchBar.showsCancelButton = true
        aquaSearchBar.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension AquaSearchController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if let delegate = self.delegate as? AquaSearchDelegate {
            delegate.didStartSearch()
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let delegate = self.delegate as? AquaSearchDelegate {
            delegate.didTapSearch()
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let delegate = self.delegate as? AquaSearchDelegate {
            delegate.didTapCancel()
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let delegate = self.delegate as? AquaSearchDelegate {
            delegate.didStartSearch()
        }
    }
}
