import UIKit
import Vision
import CoreImage

final class QRCodeScreenshotReader {

    private weak var delegate: QRScannerDelegate?

    init(delegate: QRScannerDelegate) {
        self.delegate = delegate
    }

    func qrCode(from image: UIImage) {
        guard let cgImage = image.cgImage else {
            delegate?.scanningFailed(with: ScanningError.screenshotInvalid)
            return
        }
        scanImage(cgImage: cgImage)
    }

    private func scanImage(cgImage: CGImage) {
        let request = VNDetectBarcodesRequest(completionHandler: { [unowned self] request, error in
            guard let results = request.results, error == nil else {
                self.delegate?.scanningFailed(with: error!)
                return
            }

            for result in results {
                if let code = result as? VNBarcodeObservation {
                    if let payload = code.payloadStringValue, code.symbology == .QR {
                        self.delegate?.didScanQRCode(with: payload)
                        return
                    }
                }
                self.delegate?.scanningFailed(with: ScanningError.qrCodeNotFound)
            }
        })

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [.properties: ""])

        do {
            try handler.perform([request])
        } catch {
            self.delegate?.scanningFailed(with: error)
        }
    }
}
