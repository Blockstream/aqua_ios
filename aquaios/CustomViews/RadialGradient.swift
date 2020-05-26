import UIKit

class RadialGradient: CALayer {

    var center: CGPoint = CGPoint(x: 0, y: 0)
    var radius: CGFloat = 192
    var colors = [UIColor.gradientGreen.cgColor,
                  UIColor.gradientBlue.cgColor]

    override init() {
        super.init()
        needsDisplayOnBoundsChange = true
    }

    init(center: CGPoint, radius: CGFloat, colors: [CGColor]) {
        self.center = center
        self.radius = radius
        self.colors = colors
        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        super.init()
    }

    override func draw(in ctx: CGContext) {
        ctx.saveGState()
        let colorspace = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [0.0, 1.0]
        if let gradient = CGGradient(colorsSpace: colorspace, colors: colors as CFArray, locations: locations) {
            ctx.drawRadialGradient(gradient,
                                   startCenter: center,
                                   startRadius: 0.0,
                                   endCenter: center,
                                   endRadius: radius,
                                   options: .drawsAfterEndLocation)
        }
    }
}

class RadialGradientView: UIView {
    private let gradientLayer = RadialGradient()

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.center = self.center
        if gradientLayer.superlayer == nil {
            layer.insertSublayer(gradientLayer, at: 0)
        }
        gradientLayer.frame = bounds
    }
}
