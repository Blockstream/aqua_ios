import UIKit

class RadialGradient: CALayer {

    var center: CGPoint = CGPoint(x: 0, y: 0)
    var radius: CGFloat = 304
    var colors = [UIColor.topaz.cgColor,
                  UIColor.deepTeal.cgColor]

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
    let gradient = RadialGradient()

    override func layoutSubviews() {
        super.layoutSubviews()

        if gradient.superlayer != nil {
            return
        }

        let path = createPath()
        gradient.frame = path.bounds
        gradient.center = CGPoint(x: self.center.x, y: -112)
        gradient.radius = 304

        let shapeMask = CAShapeLayer()
        shapeMask.path = path.cgPath
        gradient.mask = shapeMask
        self.layer.addSublayer(gradient)
    }

    func createPath() -> UIBezierPath {
        let path = UIBezierPath()
        let curveHeight = CGFloat(50)
        let height = self.frame.size.height - curveHeight

        path.move(to: CGPoint(x: 0.0, y: 0.0))
        path.addLine(to: CGPoint(x: 0.0, y: height))
        path.addLine(to: CGPoint(x: self.frame.size.width, y: height))
        path.addLine(to: CGPoint(x: self.frame.size.width, y: 0.0))

        path.move(to: CGPoint(x: 0.0, y: height))
        path.addQuadCurve(to: CGPoint(x: self.frame.size.width, y: height),
                          controlPoint: CGPoint(x: self.frame.size.width/2, y: self.frame.size.height + curveHeight))

        path.close()
        return path
    }
}
