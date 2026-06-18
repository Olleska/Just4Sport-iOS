import UIKit

extension UIFont {
    enum Bold {
        private static let app = UIFont(name: "Inter-Bold", size: 28)!
        static let body = scaledFont(for: app.withSize(16), textStyle: .body)
        static let title1 = scaledFont(for: app.withSize(40), textStyle: .title1)
        static let callout = scaledFont(for: app.withSize(14), textStyle: .callout)
        static let title2 = scaledFont(for: app.withSize(32), textStyle: .title2)
        static let footnote = scaledFont(for: app.withSize(14), textStyle: .footnote)
        static let title3 = scaledFont(for: app.withSize(20), textStyle: .title3)
    }
    enum Regular {
        private static let app = UIFont(name: "Inter-Regular", size: 28)!
        static let body = scaledFont(for: app.withSize(16), textStyle: .body)
        static let callout = scaledFont(for: app.withSize(18), textStyle: .callout)
        private static let app2 = UIFont(name: "IBMPlexSans-Medium", size: 28)!
        static let footnote = scaledFont(for: app2.withSize(14), textStyle: .footnote)
    }
    enum SemiBold {
        private static let app = UIFont(name: "Inter-SemiBold", size: 28)!
        static let body = scaledFont(for: app.withSize(16), textStyle: .body)
        static let title1 = scaledFont(for: app.withSize(24), textStyle: .title1)
        static let title2 = scaledFont(for: app.withSize(20), textStyle: .title2)
    }
    static func scaledFont(for font: UIFont?, textStyle: UIFont.TextStyle) -> UIFont? {
        guard let font else { return nil }
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: font)
    }
}
