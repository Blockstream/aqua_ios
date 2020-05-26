import UIKit
import AVKit
import Foundation

enum ScanningError: Error {
    case qrCodeNotFound
    case addressInvalid
    case screenshotInvalid
}

protocol QRScannerDelegate: class {
    func didScanQRCode(with address: String)
    func scanningFailed(with error: Error)
}

class QRScanner: NSObject {

    private var captureSession: AVCaptureSession!
    private weak var delegate: QRScannerDelegate?

    init(with view: UIView, delegate: QRScannerDelegate) {
        self.delegate = delegate
        super.init()
        if let captureSession = createCaptureSession() {
            self.captureSession = captureSession
            let previewLayer = createPreviewLayer(with: captureSession, view: view)
            view.layer.addSublayer(previewLayer)
        }
    }

    func requestCaptureSessionStart() {
        guard let captureSession = captureSession else {
            return
        }

        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }

    func requestCaptureSettingStop() {
        guard let captureSession = captureSession else {
            return
        }

        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }

    private func createCaptureSession() -> AVCaptureSession? {
        let captureSession = AVCaptureSession()

        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            return nil
        }
        do {
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            let metaDataOutput = AVCaptureMetadataOutput()

            if captureSession.canAddInput(deviceInput) {
                captureSession.addInput(deviceInput)
            } else {
                return nil
            }

            if captureSession.canAddOutput(metaDataOutput) {
                captureSession.addOutput(metaDataOutput)

                metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metaDataOutput.metadataObjectTypes = metaObjectTypes()
            } else {
                return nil
            }
        } catch {
            return nil
        }

        return captureSession
    }

    private func createPreviewLayer(with captureSession: AVCaptureSession, view: UIView) -> AVCaptureVideoPreviewLayer {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        return previewLayer
    }

    private func metaObjectTypes() -> [AVMetadataObject.ObjectType] {
        return [.aztec,
                .code128,
                .code39,
                .code39Mod43,
                .code93,
                .dataMatrix,
                .ean13,
                .ean8,
                .interleaved2of5,
                .itf14,
                .pdf417,
                .qr,
                .upce]
    }
}

// MARK: - QRCode Scanning

extension QRScanner: AVCaptureMetadataOutputObjectsDelegate {

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        readOutput(output, didOutput: metadataObjects, from: connection)
    }

    func readOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        requestCaptureSettingStop()
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            // we would check before return that is valid bitcoin/liquid address
            delegate?.didScanQRCode(with: stringValue)
        }
    }
}
