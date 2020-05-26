import UIKit
import Foundation

extension UIImage {
    convenience init?(base64 str: String?) {
        guard let str = str, let encodedData = Data(base64Encoded: str) else { return nil }
        self.init(data: encodedData)
    }

    convenience init?(color: UIColor, in frame: CGRect) {
        UIGraphicsBeginImageContext(frame.size)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(frame)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            guard let cgImage = image?.cgImage else { return nil }
            self.init(cgImage: cgImage)
        }
        return nil
    }
}
