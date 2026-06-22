import UIKit

class textDescriptionComponent: UIView, UITextViewDelegate {
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = .SemiBold.body
        label.textColor = UIColor(named: "redColor")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = .Regular.body
        textView.backgroundColor = .clear
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 2
        textView.layer.borderColor = UIColor(named: "redColor")?.withAlphaComponent(0.2).cgColor
        textView.textColor = .black
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = .Regular.body
        label.textColor = UIColor.black.withAlphaComponent(0.5)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [textLabel, textView])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        textView.delegate = self
    }
    required init?(coder: NSCoder) {
        fatalError("cat")
    }
    
    func configure(title: String, placeholder: String) {
        textLabel.text = title
        placeholderLabel.text = placeholder
    }
    
    private func setupLayout() {
        addSubview(stackView)
        textView.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 12),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -16)
        ])
    }
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    func clear() {
        textView.text = ""
        placeholderLabel.isHidden = false
    }
}
