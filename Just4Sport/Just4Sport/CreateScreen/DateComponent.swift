import UIKit

class dateSelectComponent: UIView {

    var onDateSelected: ((Date) -> Void)?
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy, HH:mm"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = .SemiBold.body
        label.textColor = UIColor(named: "redColor")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.font = .Regular.body
        textField.backgroundColor = .clear
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor(named: "redColor")?.withAlphaComponent(0.2).cgColor
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.textColor = .black
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 48).isActive = true
        textField.inputView = datePicker
        textField.inputAccessoryView = createToolbar()
        return textField
    }()
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .wheels
        picker.tintColor = UIColor(named: "redColor")
        picker.locale = Locale(identifier: "ru_RU")
        picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return picker
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
    required init?(coder: NSCoder) {
        fatalError("cat")
    }
    func configure(title: String, placeholder: String) {
        textLabel.text = title
        textField.placeholder = placeholder
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.5)]
        )
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
    private func createToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(donePressed))
        doneButton.tintColor = UIColor(named: "redColor")
        toolbar.setItems([flexSpace, doneButton], animated: false)
        return toolbar
    }
    @objc private func dateChanged() {
        textField.text = dateFormatter.string(from: datePicker.date)
        onDateSelected?(datePicker.date)
    }
    @objc private func donePressed() {
        if textField.text?.isEmpty == true {
            dateChanged()
        }
        endEditing(true)
    }
    func clear() {
        textField.text = ""
    }
}
