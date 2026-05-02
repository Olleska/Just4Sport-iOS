import UIKit

final class CustomComponent: UIView {
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = .Bold.body
        label.textColor = UIColor(named: "redColor")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.font = .Regular.body
        textField.backgroundColor = UIColor(named: "grayColor")?.withAlphaComponent(0.2)
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 0
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.textColor = .black
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return textField
    }()
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [textLabel, textField])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    required init ?(coder: NSCoder) {
        fatalError("cat")
    }
    func configure(title: String, placeholder: String, isSecure: Bool) {
        textLabel.text = title
        textField.placeholder = placeholder
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.5)]
        )
        textField.isSecureTextEntry = isSecure
    }
    private func setupLayout() {
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
