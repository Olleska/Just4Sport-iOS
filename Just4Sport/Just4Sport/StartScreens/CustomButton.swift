import UIKit

enum CustomButtonStyle {
    case firstType
    case secondType
}

final class CustomButton: UIControl {
    private let style: CustomButtonStyle
    lazy var label: UILabel = {
        let label = UILabel()
        label.font = .Bold.body
        label.textAlignment = .center
        return label
    }()
    override var intrinsicContentSize: CGSize {
        CGSize(width: self.bounds.width, height: 56)
    }
    override var isHighlighted: Bool {
        didSet {
            updateHighlighted()
        }
    }
    init(style: CustomButtonStyle) {
        self.style = style
        super.init(frame: .zero)
        setup()
        layoutComponents()
    }
    required init?(coder: NSCoder) {
        fatalError("cat")
    }
    func setText(_ text: String) {
        label.text = text
    }
    private func setup() {
        layer.cornerRadius = 16
        clipsToBounds = true
        switch style {
        case .firstType:
            backgroundColor = UIColor(named: "redColor")
            label.textColor = .white
        case .secondType:
            backgroundColor = UIColor(named: "grayColor")?.withAlphaComponent(0.2)
            label.textColor = UIColor(named: "redColor")
        }
    }
    private func layoutComponents() {
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16)
        ])
    }
    private func updateHighlighted() {
        alpha = isHighlighted ? 0.7 : 1.0
    }
}

