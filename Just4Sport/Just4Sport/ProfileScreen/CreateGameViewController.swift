import UIKit

final class CreateGameViewController: UIViewController {
    
    private let eventId: String
    private let teams: [ParticipantTeamModel]
    private var selectedFirstTeamId: String?
    private var selectedSecondTeamId: String?
    private let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    private let scrollView = UIScrollView()
    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.distribution = .fill
        return stack
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Создание игры"
        label.font = .Bold.title2
        label.textColor = .black
        return label
    }()
    
    private let dateTextField = CreateGameViewController.makeTextField(placeholder: "Выберите дату и время")
    private let firstTeamTextField = CreateGameViewController.makeTextField(placeholder: "Выберите первую команду")
    private let secondTeamTextField = CreateGameViewController.makeTextField(placeholder: "Выберите вторую команду")
    
    private let datePicker = UIDatePicker()
    private let firstTeamPicker = UIPickerView()
    private let secondTeamPicker = UIPickerView()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать матч", for: .normal)
        button.titleLabel?.font = .Bold.body
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "redColor") ?? .systemRed
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Назад", for: .normal)
        button.titleLabel?.font = .Bold.body
        button.setTitleColor(UIColor(named: "redColor") ?? .systemRed, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = (UIColor(named: "redColor") ?? .systemRed).cgColor
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    init(eventId: String, teams: [ParticipantTeamModel]) {
        self.eventId = eventId
        self.teams = teams
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("cat")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.hidesBackButton = true
        setupLayout()
        setupPickers()
    }
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(createFormRow(title: "Дата и время игры", inputView: dateTextField))
        contentStackView.addArrangedSubview(createFormRow(title: "Команда 1", inputView: firstTeamTextField))
        contentStackView.addArrangedSubview(createFormRow(title: "Команда 2", inputView: secondTeamTextField))
        contentStackView.setCustomSpacing(32, after: secondTeamTextField.superview ?? secondTeamTextField)
        contentStackView.addArrangedSubview(createButton)
        contentStackView.setCustomSpacing(12, after: createButton)
        contentStackView.addArrangedSubview(backButton)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 75),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            createButton.heightAnchor.constraint(equalToConstant: 48),
            backButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    private func setupPickers() {
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        dateTextField.inputView = datePicker
        firstTeamPicker.delegate = self
        firstTeamPicker.dataSource = self
        firstTeamTextField.inputView = firstTeamPicker
        secondTeamPicker.delegate = self
        secondTeamPicker.dataSource = self
        secondTeamTextField.inputView = secondTeamPicker
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Готово", style: .plain, target: self, action: #selector(dismissKeyboard))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([space, doneButton], animated: false)
        dateTextField.inputAccessoryView = toolbar
        firstTeamTextField.inputAccessoryView = toolbar
        secondTeamTextField.inputAccessoryView = toolbar
    }
    @objc private func dateChanged() {
        dateTextField.text = displayDateFormatter.string(from: datePicker.date)
    }
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    @objc private func createButtonTapped() {
        guard let firstTeamId = selectedFirstTeamId,
              let secondTeamId = selectedSecondTeamId,
              let dateText = dateTextField.text, !dateText.isEmpty else {
            showErrorAlert(message: "Пожалуйста, заполните все поля.")
            return
        }
        if firstTeamId == secondTeamId {
            showErrorAlert(message: "Команда не может играть сама с собой. Выберите разные команды.")
            return
        }
        print("Создаем игру между \(firstTeamId) и \(secondTeamId) на дату \(datePicker.date)")
    }
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }

    private func createFormRow(title: String, inputView: UIView) -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        let label = UILabel()
        label.text = title
        label.font = .SemiBold.body
        label.textColor = UIColor(named: "redColor")
        stack.addArrangedSubview(label)
        stack.addArrangedSubview(inputView)
        return stack
    }
    
    private static func makeTextField(placeholder: String) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.font = .Regular.body
        tf.textColor = .black
        tf.backgroundColor = .systemGray6
        tf.layer.cornerRadius = 12
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 44))
        tf.leftView = paddingView
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return tf
    }
}

extension CreateGameViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return teams.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return teams[row].name
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard !teams.isEmpty else { return }
        let selectedTeam = teams[row]
        if pickerView == firstTeamPicker {
            firstTeamTextField.text = selectedTeam.name
            selectedFirstTeamId = selectedTeam.id
        } else if pickerView == secondTeamPicker {
            secondTeamTextField.text = selectedTeam.name
            selectedSecondTeamId = selectedTeam.id
        }
    }
}
