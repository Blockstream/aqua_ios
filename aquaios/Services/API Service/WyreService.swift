import Foundation

struct WyreWidget: Codable {
    var geoIpLocation: WyreLocation?
    var hasRestrictions: Bool?
}

struct WyreLocation: Codable {
    var city: String?
    var country: String?
    var countryCode: String?
    var subRegion: String?
    var latitude: Float?
    var longitude: Float?
}

protocol WyreServiceDelegate: class {
    func widgetRetrieved(with widget: WyreWidget)
    func requestFailed(with error: Error)
}

final class WyreService {

    private weak var delegate: WyreServiceDelegate?
    private let client = APIClient(baseURL: URL(string: "https://api.sendwyre.com/v2/")!)

    init(delegate: WyreServiceDelegate) {
        self.delegate = delegate
    }

    func getWidget() {
        let request = APIRequest(method: .get, path: "location/widget")
        request.headers = [HTTPHeader(field: "Content-Type", value: "application/json")]

        client.request(request) { [weak self] (_, data, error) in
            guard error == nil else {
                self?.delegate?.requestFailed(with: error!)
                return
            }

            if let data = data, error == nil {
                if let widget = try? JSONDecoder().decode(WyreWidget.self, from: data), let delegate = self?.delegate {
                    delegate.widgetRetrieved(with: widget)
                }
            } else {
                self?.delegate?.requestFailed(with: APIError.requestFailed)
            }
        }
    }
}
