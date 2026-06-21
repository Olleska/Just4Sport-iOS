import UIKit

final class EditEventViewController: UIViewController {
    private let eventId: String
    private var eventDetails: EventDetailModel
    private let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        scroll.keyboardDismissMode = .onDrag
        return scroll
    }()
    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.distribution = .fill
        return stack
    }()
    private let nameTextField = EditEventViewController.makeTextField(placeholder: "Название мероприятия")
    private let placeTextField = EditEventViewController.makeTextField(placeholder: "Место проведения")
    private let costTextField = EditEventViewController.makeTextField(placeholder: "Стоимость", keyboardType: .numberPad)
    private let teamsTextField = EditEventViewController.makeTextField(placeholder: "Количество команд", keyboardType: .numberPad)
    private let descriptionTextView: UITextView = {
        let tv = UITextView()
        tv.font = .Regular.body
        tv.textColor = .black
        tv.backgroundColor = .systemGray6
        tv.layer.cornerRadius = 12
        tv.isScrollEnabled = false
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        return tv
    }()
    private let startDateTextField = EditEventViewController.makeTextField(placeholder: "Дата начала")
    private let endDateTextField = EditEventViewController.makeTextField(placeholder: "Дата окончания")
    private let deadlineTextField = EditEventViewController.makeTextField(placeholder: "Дедлайн подачи заявки")
    private let startDatePicker = UIDatePicker()
    private let endDatePicker = UIDatePicker()
    private let deadlineDatePicker = UIDatePicker()
    private lazy var closeRegistrationButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .Bold.body
        button.setTitleColor(UIColor(named: "greenColor"), for: .normal)
        button.backgroundColor = UIColor(named: "greenColor")?.withAlphaComponent(0.2) ?? .systemRed
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(closeRegistrationButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Сохранить изменения", for: .normal)
        button.titleLabel?.font = .Bold.body
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "redColor") ?? .systemRed
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var finishEventButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Завершить мероприятие", for: .normal)
        button.titleLabel?.font = .Bold.body
        button.setTitleColor(UIColor(named: "yellowColor"), for: .normal)
        button.backgroundColor = UIColor(named: "yellowColor")?.withAlphaComponent(0.2) ?? .systemGray5
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(finishEventButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var cancelEventButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить мероприятие", for: .normal)
        button.titleLabel?.font = .Bold.body
        button.setTitleColor(UIColor(named: "yellowColor"), for: .normal)
        button.backgroundColor = UIColor(named: "yellowColor")?.withAlphaComponent(0.2) ?? .systemGray5
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(cancelEventButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var deleteEventButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Удалить мероприятие", for: .normal)
        button.titleLabel?.font = .Bold.body
        button.setTitleColor(UIColor(named: "redColor"), for: .normal)
        button.backgroundColor = UIColor(named: "redColor")?.withAlphaComponent(0.2)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(deleteEventButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Назад", for: .normal)
        button.titleLabel?.font = .Bold.body
        button.setTitleColor(UIColor(named: "redColor") ?? .systemRed, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = (UIColor(named: "redColor") ?? .systemRed).cgColor
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    init(eventId: String, eventDetails: EventDetailModel) {
        self.eventId = eventId
        self.eventDetails = eventDetails
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
        setupDatePickers()
        configureUIWithCurrentData()
        setupKeyboardDismissRecognizer()
    }
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.addArrangedSubview(createFormRow(title: "Название мероприятия", inputView: nameTextField))
        contentStackView.addArrangedSubview(createFormRow(title: "Описание", inputView: descriptionTextView))
        contentStackView.addArrangedSubview(createFormRow(title: "Дата начала", inputView: startDateTextField))
        contentStackView.addArrangedSubview(createFormRow(title: "Дата окончания", inputView: endDateTextField))
        contentStackView.addArrangedSubview(createFormRow(title: "Место проведения", inputView: placeTextField))
        contentStackView.addArrangedSubview(createFormRow(title: "Стоимость участия", inputView: costTextField))
        contentStackView.addArrangedSubview(createFormRow(title: "Дедлайн подачи заявки", inputView: deadlineTextField))
        contentStackView.addArrangedSubview(createFormRow(title: "Количество команд", inputView: teamsTextField))
        contentStackView.setCustomSpacing(32, after: teamsTextField.superview ?? teamsTextField)
        contentStackView.addArrangedSubview(closeRegistrationButton)
        contentStackView.setCustomSpacing(12, after: closeRegistrationButton)
        contentStackView.addArrangedSubview(finishEventButton)
        contentStackView.setCustomSpacing(12, after: finishEventButton)
        contentStackView.addArrangedSubview(cancelEventButton)
        contentStackView.setCustomSpacing(12, after: cancelEventButton)
        contentStackView.addArrangedSubview(deleteEventButton)
        contentStackView.setCustomSpacing(12, after: deleteEventButton)
        contentStackView.addArrangedSubview(saveButton)
        contentStackView.setCustomSpacing(12, after: saveButton)
        contentStackView.addArrangedSubview(backButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        deleteEventButton.translatesAutoresizingMaskIntoConstraints = false
        closeRegistrationButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 57),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 48),
            backButton.heightAnchor.constraint(equalToConstant: 48),
            deleteEventButton.heightAnchor.constraint(equalToConstant: 48),
            closeRegistrationButton.heightAnchor.constraint(equalToConstant: 48),
            finishEventButton.heightAnchor.constraint(equalToConstant: 48),
            cancelEventButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    private func configureUIWithCurrentData() {
        nameTextField.text = eventDetails.name
        descriptionTextView.text = eventDetails.description
        placeTextField.text = eventDetails.place
        costTextField.text = eventDetails.visibleCost.replacingOccurrences(of: " ₽", with: "")
        teamsTextField.text = "1"
        startDateTextField.text = eventDetails.visibleStartDate
        endDateTextField.text = eventDetails.visibleEndDate
        deadlineTextField.text = eventDetails.visibleDeadline
        startDatePicker.date = Date()
        endDatePicker.date = Date()
        deadlineDatePicker.date = Date()
        updateCloseRegistrationButton()
    }
    private func updateCloseRegistrationButton() {
        if eventDetails.eventStatus == "WILL_BE" {
            closeRegistrationButton.setTitle("Закрыть регистрацию", for: .normal)
            closeRegistrationButton.isEnabled = true
            closeRegistrationButton.layer.borderWidth = 0
        } else {
            closeRegistrationButton.setTitle("Регистрация уже закрыта", for: .normal)
            closeRegistrationButton.isEnabled = false
            closeRegistrationButton.layer.borderWidth = 0
        }
    }
    private func setupDatePickers() {
        configureDatePicker(startDatePicker, for: startDateTextField, action: #selector(startDateChanged))
        configureDatePicker(endDatePicker, for: endDateTextField, action: #selector(endDateChanged))
        configureDatePicker(deadlineDatePicker, for: deadlineTextField, action: #selector(deadlineChanged))
    }
    private func configureDatePicker(_ picker: UIDatePicker, for textField: UITextField, action: Selector) {
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "ru_RU")
        textField.inputView = picker
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Готово", style: .plain, target: self, action: #selector(dismissKeyboard))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([space, doneButton], animated: false)
        textField.inputAccessoryView = toolbar
        picker.addTarget(self, action: action, for: .valueChanged)
    }
    @objc private func startDateChanged() {
        startDateTextField.text = displayDateFormatter.string(from: startDatePicker.date)
    }
    @objc private func endDateChanged() {
        endDateTextField.text = displayDateFormatter.string(from: endDatePicker.date)
    }
    @objc private func deadlineChanged() {
        deadlineTextField.text = displayDateFormatter.string(from: deadlineDatePicker.date)
    }
    @objc private func saveButtonTapped() {
        saveButton.isEnabled = false
        let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let description = descriptionTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let place = placeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let cost = Int(costTextField.text ?? "") ?? 0
        let teamsNumber = Int(teamsTextField.text ?? "") ?? 1
        let dateStartStr = backendDateFormatter.string(from: startDatePicker.date)
        let dateEndStr = backendDateFormatter.string(from: endDatePicker.date)
        let deadlineStr = backendDateFormatter.string(from: deadlineDatePicker.date)
        if name.isEmpty || place.isEmpty {
            showErrorAlert(message: "Пожалуйста, заполните название и место проведения.")
            saveButton.isEnabled = true
            return
        }
        let requestModel = EditEventRequest(
            name: name,
            description: description,
            dateStart: dateStartStr,
            dateEnd: dateEndStr,
            place: place,
            cost: cost,
            deadline: deadlineStr,
            teamsNumber: teamsNumber
        )
        print("Отправка PUT запроса для id: \(eventId)")
        EventNetworkService.shared.updateEventDetails(id: eventId, requestModel: requestModel) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.saveButton.isEnabled = true
                switch result {
                case .success:
                    print("Мероприятие успешно обновлено!")
                    self.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    print("Ошибка при обновлении: \(error.localizedDescription)")
                    self.showErrorAlert(message: "Не удалось сохранить изменения. Попробуйте позже.")
                }
            }
        }
    }
    @objc private func closeRegistrationButtonTapped() {
        closeRegistrationButton.isEnabled = false
        EventNetworkService.shared.closeRegistration(id: eventId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.closeRegistrationButton.isEnabled = true
                switch result {
                case .success:
                    print("Регистрация успешно закрыта!")
                    self.updateCloseRegistrationButton()
                    let alert = UIAlertController(title: "Успешно", message: "Регистрация на мероприятие успешно закрыта.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ОК", style: .default))
                    self.present(alert, animated: true)
                case .failure(let error):
                    print("Ошибка при закрытии регистрации: \(error.localizedDescription)")
                    self.showErrorAlert(message: "Не удалось закрыть регистрацию. Возможно, у вас нет прав организатора.")
                }
            }
        }
    }
    @objc private func finishEventButtonTapped() {
        finishEventButton.isEnabled = false
        EventNetworkService.shared.finishEvent(id: eventId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.finishEventButton.isEnabled = true
                switch result {
                case .success:
                    print("Мероприятие успешно завершено!")
                    self.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    print("Ошибка при завершении мероприятия: \(error.localizedDescription)")
                    self.showErrorAlert(message: "Не удалось завершить мероприятие. Попробуйте позже.")
                }
            }
        }
    }
    @objc private func cancelEventButtonTapped() {
        let alert = UIAlertController(
            title: "Отмена мероприятия",
            message: "Вы уверены, что хотите отменить это мероприятие?",
            preferredStyle: .alert
        )
        let confirmAction = UIAlertAction(title: "Отменить", style: .destructive) { [weak self] _ in
            self?.performCancelEvent()
        }
        let cancelAction = UIAlertAction(title: "Назад", style: .cancel)
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    private func performCancelEvent() {
        cancelEventButton.isEnabled = false
        EventNetworkService.shared.cancelEvent(id: eventId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.cancelEventButton.isEnabled = true
                switch result {
                case .success:
                    print("Мероприятие успешно отменено!")
                    let alert = UIAlertController(title: "Отменено", message: "Мероприятие было отменено.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ОК", style: .default) { _ in
                        self.navigationController?.popViewController(animated: true)
                    })
                    self.present(alert, animated: true)
                case .failure(let error):
                    print("Ошибка при отмене мероприятия: \(error.localizedDescription)")
                    self.showErrorAlert(message: "Не удалось отменить мероприятие. Попробуйте позже.")
                }
            }
        }
    }
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    @objc private func deleteEventButtonTapped() {
        let alert = UIAlertController(
            title: "Удаление мероприятия",
            message: "Вы уверены, что хотите полностью удалить это мероприятие? Данное действие нельзя будет отменить.",
            preferredStyle: .alert
        )
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.performDeleteEvent()
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    private func performDeleteEvent() {
        deleteEventButton.isEnabled = false
        EventNetworkService.shared.deleteEvent(id: eventId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.deleteEventButton.isEnabled = true
                switch result {
                case .success:
                    print("Мероприятие успешно удалено!")
                    let successAlert = UIAlertController(title: "Успешно", message: "Мероприятие было удалено.", preferredStyle: .alert)
                    successAlert.addAction(UIAlertAction(title: "ОК", style: .default) { _ in
                        if let viewControllers = self.navigationController?.viewControllers, viewControllers.count >= 3 {
                            let targetVC = viewControllers[viewControllers.count - 3]
                            self.navigationController?.popToViewController(targetVC, animated: true)
                        } else {
                            self.navigationController?.popViewController(animated: true)
                        }
                    })
                    self.present(successAlert, animated: true)
                case .failure(let error):
                    print("Ошибка при удалении: \(error.localizedDescription)")
                }
            }
        }
    }
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
    @objc private func dismissKeyboard() {
        view.endEditing(true)
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
    
    private static func makeTextField(placeholder: String, keyboardType: UIKeyboardType = .default) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.font = .Regular.body
        tf.textColor = .black
        tf.backgroundColor = .systemGray6
        tf.layer.cornerRadius = 12
        tf.keyboardType = keyboardType
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 44))
        tf.leftView = paddingView
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return tf
    }
    private func setupKeyboardDismissRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    private let backendDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}
