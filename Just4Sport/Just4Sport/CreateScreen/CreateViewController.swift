import UIKit

class CreateViewController: UIViewController {
    // 1. В самом верху класса объявляем сервис
    private let networkService = EventNetworkService.shared

    // 2. Добавляем хелперы для конвертации UI-строк в серверные энумы
    private func getSportBackendKey(for UIValue: String) -> String {
        switch UIValue {
        case "Волейбол": return "VOLLEYBALL"
        case "Баскетбол": return "BASKETBALL"
        case "Алтимат": return "ULTIMATE"
        case "Футбол": return "SOCCER"
        case "Хоккей": return "HOCKEY"
        default: return "VOLLEYBALL"
        }
    }

    private func getTypeBackendKey(for UIValue: String) -> String {
        switch UIValue {
        case "Тренировка": return "TRAINING"
        case "Игра": return "GAME"
        case "Турнир": return "TOURNAMENT"
        default: return "TRAINING"
        }
    }

    private func getLevelBackendKey(for UIValue: String) -> String {
        switch UIValue {
        case "Новички": return "START"
        case "Любители": return "MEDIUM"
        case "Профессионалы": return "HARD"
        default: return "START"
        }
    }

    // 3. Хелпер для дат. Если твои компоненты возвращают строку (например "18 июня 2026, 22:04"),
    // нужно превратить её в ISO8601 string.
    // (Примечание: если внутри dateSelectComponent у тебя хранится чистый Date, лучше вытащить его напрямую!)
    private func formatToISO8601(dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd MMMM yyyy, HH:mm" // Подставь формат, который генерирует твой пикер
        inputFormatter.locale = Locale(identifier: "ru_RU")
        
        guard let date = inputFormatter.date(from: dateString) else {
            // Фолбек: если не распарсилось, возвращаем текущую дату в ISO формате
            return ISO8601DateFormatter().string(from: Date())
        }
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]
        return isoFormatter.string(from: date)
    }
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = true
        scroll.alwaysBounceVertical = true
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "JUST 4SPORT"
        label.font = .Bold.title2
        label.textColor = UIColor(named: "redColor")
        return label
    }()
    private lazy var startDateEvent: dateSelectComponent = {
        let component = dateSelectComponent()
        component.configure(title: "Дата начала мероприятия", placeholder: "Выберите дату и время")
        return component
    }()
    private lazy var endDateEvent: dateSelectComponent = {
        let component = dateSelectComponent()
        component.configure(title: "Дата завершения мероприятия", placeholder: "Выберите дату и время")
        return component
    }()
    private lazy var deadlineDateEvent: dateSelectComponent = {
        let component = dateSelectComponent()
        component.configure(title: "Дата завершения регистрации", placeholder: "Выберите дату и время")
        return component
    }()
    private lazy var nameEvent: textComponent = {
        let component = textComponent()
        component.configure(title: "Название мероприятия", placeholder: "Введите название мероприятия")
        return component
    }()
    private lazy var placeEvent: textComponent = {
        let component = textComponent()
        component.configure(title: "Место проведения", placeholder: "Введите место проведения")
        return component
    }()
    private lazy var descriptionEvent: textDescriptionComponent = {
        let component = textDescriptionComponent()
        component.configure(title: "Описание мероприятия", placeholder: "Введите описание мероприятия")
        return component
    }()
    private lazy var sportSelectionEvent: sportSelectComponent = {
        let component = sportSelectComponent()
        let mockSports = ["Волейбол", "Баскетбол", "Алтимат", "Футбол", "Хоккей"]
        component.configure(title: "Выберите вид спорта", sports: mockSports)
        component.onValueSelected = { [weak self] in
            self?.updateCreateButton()
        }
        return component
    }()
    private lazy var skillLevelEvent: sportSelectComponent = {
        let component = sportSelectComponent()
        let mockLevels = ["Профессионалы", "Любители", "Новички"]
        component.configure(title: "Выберите уровень", sports: mockLevels)
        component.onValueSelected = { [weak self] in
            self?.updateCreateButton()
        }
        return component
    }()
    private lazy var typeEvent: sportSelectComponent = {
        let component = sportSelectComponent()
        let mockTypes = ["Тренировка", "Игра", "Турнир"]
        component.configure(title: "Выберите уровень", sports: mockTypes)
        component.onValueSelected = { [weak self] in
            self?.updateCreateButton()
        }
        return component
    }()
    private lazy var costEvent: textComponent = {
        let component = textComponent()
        component.configure(title: "Стоимость участия в мероприятии", placeholder: "Введите стоимость")
        return component
    }()
    private lazy var teamNumberEvent: textComponent = {
        let component = textComponent()
        component.configure(title: "Количество команд", placeholder: "Введите количество команд")
        return component
    }()
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Создать мероприятие", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "redColor")
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .Bold.body
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        view.backgroundColor = .white
        setup()
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        nameEvent.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        placeEvent.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        costEvent.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        teamNumberEvent.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        startDateEvent.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        endDateEvent.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        deadlineDateEvent.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        updateCreateButton()
    }
    @objc private func textFieldDidChange() {
        updateCreateButton()
    }
    func setup() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        view.addSubview(titleLabel)
        containerView.addSubview(nameEvent)
        containerView.addSubview(placeEvent)
        containerView.addSubview(descriptionEvent)
        containerView.addSubview(sportSelectionEvent)
        containerView.addSubview(skillLevelEvent)
        containerView.addSubview(typeEvent)
        containerView.addSubview(costEvent)
        containerView.addSubview(teamNumberEvent)
        containerView.addSubview(startDateEvent)
        containerView.addSubview(endDateEvent)
        containerView.addSubview(deadlineDateEvent)
        containerView.addSubview(createButton)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        nameEvent.translatesAutoresizingMaskIntoConstraints = false
        placeEvent.translatesAutoresizingMaskIntoConstraints = false
        descriptionEvent.translatesAutoresizingMaskIntoConstraints = false
        sportSelectionEvent.translatesAutoresizingMaskIntoConstraints = false
        skillLevelEvent.translatesAutoresizingMaskIntoConstraints = false
        typeEvent.translatesAutoresizingMaskIntoConstraints = false
        costEvent.translatesAutoresizingMaskIntoConstraints = false
        teamNumberEvent.translatesAutoresizingMaskIntoConstraints = false
        startDateEvent.translatesAutoresizingMaskIntoConstraints = false
        endDateEvent.translatesAutoresizingMaskIntoConstraints = false
        deadlineDateEvent.translatesAutoresizingMaskIntoConstraints = false
        createButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 67),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            nameEvent.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 18),
            nameEvent.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            nameEvent.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            startDateEvent.topAnchor.constraint(equalTo: nameEvent.bottomAnchor, constant: 18),
            startDateEvent.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            startDateEvent.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            endDateEvent.topAnchor.constraint(equalTo: startDateEvent.bottomAnchor, constant: 18),
            endDateEvent.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            endDateEvent.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            descriptionEvent.topAnchor.constraint(equalTo: endDateEvent.bottomAnchor, constant: 18),
            descriptionEvent.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            descriptionEvent.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            deadlineDateEvent.topAnchor.constraint(equalTo: descriptionEvent.bottomAnchor, constant: 18),
            deadlineDateEvent.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            deadlineDateEvent.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            sportSelectionEvent.topAnchor.constraint(equalTo: deadlineDateEvent.bottomAnchor, constant: 18),
            sportSelectionEvent.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            sportSelectionEvent.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            skillLevelEvent.topAnchor.constraint(equalTo: sportSelectionEvent.bottomAnchor, constant: 18),
            skillLevelEvent.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            skillLevelEvent.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            typeEvent.topAnchor.constraint(equalTo: skillLevelEvent.bottomAnchor, constant: 18),
            typeEvent.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            typeEvent.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            placeEvent.topAnchor.constraint(equalTo: typeEvent.bottomAnchor, constant: 18),
            placeEvent.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            placeEvent.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            teamNumberEvent.topAnchor.constraint(equalTo: placeEvent.bottomAnchor, constant: 18),
            teamNumberEvent.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            teamNumberEvent.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            costEvent.topAnchor.constraint(equalTo: teamNumberEvent.bottomAnchor, constant: 18),
            costEvent.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            costEvent.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            createButton.topAnchor.constraint(equalTo: costEvent.bottomAnchor, constant: 18),
            createButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            createButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            createButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -32),
        ])
    }
    private func updateCreateButton() {
        let nameText = nameEvent.textField.text ?? ""
        let startText = startDateEvent.textField.text ?? ""
        let endText = endDateEvent.textField.text ?? ""
        let deadlineText = deadlineDateEvent.textField.text ?? ""
        let placeText = placeEvent.textField.text ?? ""
        let costText = costEvent.textField.text ?? ""
        let isSportSelected = sportSelectionEvent.selectedValue != nil
        let isSkillSelected = skillLevelEvent.selectedValue != nil
        let isTypeSelected = typeEvent.selectedValue != nil
        let isDateValid = !startText.isEmpty && !endText.isEmpty && !deadlineText.isEmpty
        let isTextValid = !nameText.isEmpty && !placeText.isEmpty && !costText.isEmpty
        let isChosenFieldsValid = isSportSelected && isSkillSelected && isTypeSelected
        let isEnabled = isDateValid && isTextValid && isChosenFieldsValid

        createButton.isUserInteractionEnabled = isEnabled
        if !isEnabled {
            createButton.backgroundColor = UIColor(named: "redColor")?.withAlphaComponent(0.5)
            createButton.titleLabel?.textColor = .white.withAlphaComponent(0.5)
        } else {
            createButton.backgroundColor = UIColor(named: "redColor")
            createButton.titleLabel?.textColor = .white
        }
    }
    @objc private func createButtonTapped() {
        let nameText = nameEvent.textField.text ?? ""
        let startText = startDateEvent.textField.text ?? ""
        let endText = endDateEvent.textField.text ?? ""
        let deadlineText = deadlineDateEvent.textField.text ?? ""
        let placeText = placeEvent.textField.text ?? ""
        let descriptionText = descriptionEvent.textView.text
        let costText = costEvent.textField.text ?? ""
        let costValue = Double(costText) ?? 0.0
        let teamText = teamNumberEvent.textField.text ?? ""
        let teamsCount = Int(teamText) ?? 1
        guard let selectedSport = sportSelectionEvent.selectedValue,
              let selectedLevel = skillLevelEvent.selectedValue,
              let selectedType = typeEvent.selectedValue else { return }
        let newEvent = EventCreateModel(
            name: nameText,
            description: descriptionText!.isEmpty ? nil : descriptionText,
            dateStart: formatToISO8601(dateString: startText),
            dateEnd: formatToISO8601(dateString: endText),
            place: placeText,
            cost: costValue,
            sport: getSportBackendKey(for: selectedSport),
            eventType: getTypeBackendKey(for: selectedType),
            skillLevel: getLevelBackendKey(for: selectedLevel),
            deadline: formatToISO8601(dateString: deadlineText),
            teamsNumber: teamsCount
        )
        createButton.isEnabled = false
        EventNetworkService.shared.createEvent(model: newEvent, photoData: nil) { [weak self] result in
            DispatchQueue.main.async {
                self?.createButton.isEnabled = true
                switch result {
                case .success:
                    self?.clearAllFields()
                    if let tabBar = self?.tabBarController {
                        tabBar.selectedIndex = 0
                    }
                case .failure(let error):
                    let alert = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ОК", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }

    private func clearAllFields() {
        nameEvent.clear()
        placeEvent.clear()
        costEvent.clear()
        teamNumberEvent.clear()
        descriptionEvent.clear()
        startDateEvent.clear()
        endDateEvent.clear()
        deadlineDateEvent.clear()
        sportSelectionEvent.resetSelection()
        skillLevelEvent.resetSelection()
        typeEvent.resetSelection()
        updateCreateButton()
    }
}
