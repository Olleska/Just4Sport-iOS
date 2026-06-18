import UIKit

protocol FilterViewControllerDelegate: AnyObject {
    func didApplyFilters(_ filters: EventFilterParameters)
}

class FilterViewController: UIViewController {
    weak var delegate: FilterViewControllerDelegate?
    private var currentFilters = EventFilterParameters()
    
    private let sports = ["BASKETBALL", "VOLLEYBALL", "HOCKEY", "ULTIMATE", "SOCCER"]
    private let types = ["TRAINING", "GAME", "TOURNAMENT"]
    private let levels = ["START", "MEDIUM", "HARD"]
    private let statuses = ["WILL_BE", "UNDERWAY", "FINISHED", "CANCELLED"]
    private let sortFields = ["DATE", "COST"]
    private let sortDirections = ["ASC", "DESC"]
    
    private var sportButtons: [UIButton] = []
    private var typeButtons: [UIButton] = []
    private var levelButtons: [UIButton] = []
    private var statusButtons: [UIButton] = []
    private var sortFieldButtons: [UIButton] = []
    private var sortDirectionButtons: [UIButton] = []
    private lazy var costStartField: UITextField = {
        let tf = createPriceField(placeholder: "От")
        return tf
    }()
    private lazy var costEndField: UITextField = {
        let tf = createPriceField(placeholder: "До")
        return tf
    }()
    private lazy var dateStartField: UITextField = {
        let tf = createDateField(placeholder: "От", tag: 1)
        return tf
    }()

    private lazy var dateEndField: UITextField = {
        let tf = createDateField(placeholder: "До", tag: 2)
        return tf
    }()
    private let backendDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }()
    private let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        return formatter
    }()
    private func createPriceField(placeholder: String) -> UITextField {
        let text = UITextField()
        text.font = .Regular.body
        text.placeholder = placeholder
        text.backgroundColor = UIColor(named: "grayColor")?.withAlphaComponent(0.2)
        text.layer.cornerRadius = 8
        text.keyboardType = .numberPad
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        text.leftView = paddingView
        text.leftViewMode = .always
        return text
    }
    private func createDateField(placeholder: String, tag: Int) -> UITextField {
        let text = UITextField()
        text.font = .Regular.body
        text.placeholder = placeholder
        text.backgroundColor = UIColor(named: "grayColor")?.withAlphaComponent(0.2)
        text.layer.cornerRadius = 8
        text.tag = tag
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        text.leftView = paddingView
        text.leftViewMode = .always
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.tag = tag
        datePicker.addTarget(self, action: #selector(datePickerChanged(_:)), for: .valueChanged)
        text.inputView = datePicker
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Готово", style: .plain, target: self, action: #selector(dismissKeyboard))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexSpace, doneButton], animated: false)
        text.inputAccessoryView = toolbar
        return text
    }
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    @objc private func datePickerChanged(_ sender: UIDatePicker) {
        let backendString = backendDateFormatter.string(from: sender.date)
        let displayString = displayDateFormatter.string(from: sender.date)
        if sender.tag == 1 {
            dateStartField.text = displayString
            currentFilters.dateStart = backendString
        } else {
            dateEndField.text = displayString
            currentFilters.dateEnd = backendString
        }
    }
    init(currentFilters: EventFilterParameters) {
        self.currentFilters = currentFilters
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("cat")
    }
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Фильтры"
        label.font = .Bold.title3
        label.textColor = .black
        return label
    }()
    private lazy var resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Сбросить", for: .normal)
        button.setTitleColor(UIColor(named: "redColor"), for: .normal)
        button.titleLabel?.font = .Regular.body
        button.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var headerStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, resetButton])
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        return stack
    }()
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        return scroll
    }()
    private func createPriceSection() -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 12
        let sectionLabel = UILabel()
        sectionLabel.text = "Цена"
        sectionLabel.font = .Bold.body
        sectionLabel.textColor = .black
        container.addArrangedSubview(sectionLabel)
        let fieldsStack = UIStackView(arrangedSubviews: [costStartField, costEndField])
        fieldsStack.axis = .horizontal
        fieldsStack.spacing = 16
        fieldsStack.distribution = .fillEqually
        fieldsStack.translatesAutoresizingMaskIntoConstraints = false
        fieldsStack.heightAnchor.constraint(equalToConstant: 44).isActive = true
        container.addArrangedSubview(fieldsStack)
        return container
    }
    private func createDateSection() -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 12
        let sectionLabel = UILabel()
        sectionLabel.text = "Дата проведения"
        sectionLabel.font = .Bold.body
        sectionLabel.textColor = .black
        container.addArrangedSubview(sectionLabel)
        let fieldsStack = UIStackView(arrangedSubviews: [dateStartField, dateEndField])
        fieldsStack.axis = .horizontal
        fieldsStack.spacing = 16
        fieldsStack.distribution = .fillEqually
        fieldsStack.translatesAutoresizingMaskIntoConstraints = false
        fieldsStack.heightAnchor.constraint(equalToConstant: 44).isActive = true
        container.addArrangedSubview(fieldsStack)
        return container
    }
    private lazy var applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Применить", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .Bold.body
        button.backgroundColor = UIColor(named: "redColor")
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(applyButtonTapped), for: .touchUpInside)
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setup()
        setupFilterSections()
    }
    private func setup() {
        view.addSubview(headerStackView)
        view.addSubview(scrollView)
        view.addSubview(applyButton)
        scrollView.addSubview(contentStackView)
        headerStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        applyButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            headerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            headerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            scrollView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            scrollView.bottomAnchor.constraint(equalTo: applyButton.topAnchor, constant: -16),
            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            applyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            applyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            applyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            applyButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    private func setupFilterSections() {
        let sportSection = createSection(title: "Вид спорта", items: sports, selectedValue: currentFilters.sport, type: .sport)
        contentStackView.addArrangedSubview(sportSection)
        let typeSection = createSection(title: "Тип мероприятия", items: types, selectedValue: currentFilters.eventType, type: .eventType)
        contentStackView.addArrangedSubview(typeSection)
        let dateSection = createDateSection()
        contentStackView.addArrangedSubview(dateSection)
        if let startISO = currentFilters.dateStart, let date = backendDateFormatter.date(from: startISO) {
            dateStartField.text = displayDateFormatter.string(from: date)
        }
        if let endISO = currentFilters.dateEnd, let date = backendDateFormatter.date(from: endISO) {
            dateEndField.text = displayDateFormatter.string(from: date)
        }
        let levelSection = createSection(title: "Уровень подготовки", items: levels, selectedValue: currentFilters.skillLevel, type: .skillLevel)
        contentStackView.addArrangedSubview(levelSection)
        let statusSection = createSection(title: "Статус мероприятия", items: statuses, selectedValue: currentFilters.status, type: .eventStatus)
        contentStackView.addArrangedSubview(statusSection)
        let priceSection = createPriceSection()
        contentStackView.addArrangedSubview(priceSection)
        if let start = currentFilters.costStart { costStartField.text = "\(start)" }
        if let end = currentFilters.costEnd { costEndField.text = "\(end)" }
        let fieldSection = createSection(title: "Сортировать", items: sortFields, selectedValue: currentFilters.sortField, type: .sortField)
        contentStackView.addArrangedSubview(fieldSection)
        let directionSection = createSection(title: "Сортировать", items: sortDirections, selectedValue: currentFilters.sortDirection, type: .sortDirection)
        contentStackView.addArrangedSubview(directionSection)
    }
    enum FilterType { case sport, eventType, skillLevel, eventStatus, sortField, sortDirection}
    private func createSection(title: String, items: [String], selectedValue: String?, type: FilterType ) -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 12
        let sectionLabel = UILabel()
        sectionLabel.text = title
        sectionLabel.font = .Bold.body
        sectionLabel.textColor = .black
        container.addArrangedSubview(sectionLabel)
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        let chipsStack = UIStackView()
        chipsStack.axis = .horizontal
        chipsStack.spacing = 8
        for item in items {
            let button = UIButton(type: .system)
            button.setTitle(getVisibleName(for: item), for: .normal)
            button.titleLabel?.font = .Regular.body
            button.layer.cornerRadius = 14
            button.configuration = .filled()
            button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 14)
            button.accessibilityIdentifier = item
            let isSelected = (item == selectedValue)
            updateButtonAppearance(button, isSelected: isSelected)
            switch type {
            case .sport:
                sportButtons.append(button)
                button.addTarget(self, action: #selector(sportChipTapped(_:)), for: .touchUpInside)
            case .eventType:
                typeButtons.append(button)
                button.addTarget(self, action: #selector(typeChipTapped(_:)), for: .touchUpInside)
            case .skillLevel:
                levelButtons.append(button)
                button.addTarget(self, action: #selector(levelChipTapped(_:)), for: .touchUpInside)
            case .eventStatus:
                statusButtons.append(button)
                button.addTarget(self, action: #selector(statusChipTapped(_:)), for: .touchUpInside)
            case .sortField:
                sortFieldButtons.append(button)
                button.addTarget(self, action: #selector(fieldChipTapped(_:)), for: .touchUpInside)
            case .sortDirection:
                sortDirectionButtons.append(button)
                button.addTarget(self, action: #selector(directionChipTapped(_:)), for: .touchUpInside)
            }
            chipsStack.addArrangedSubview(button)
        }
        scrollView.addSubview(chipsStack)
        chipsStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chipsStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            chipsStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            chipsStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            chipsStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            chipsStack.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
        container.addArrangedSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        return container
    }
    
    private func getVisibleName(for backendKey: String) -> String {
        switch backendKey {
        case "BASKETBALL": return "баскетбол"
        case "VOLLEYBALL": return "волейбол"
        case "HOCKEY": return "хоккей"
        case "ULTIMATE": return "алтимат"
        case "SOCCER": return "футбол"
        case "TRAINING": return "тренировка"
        case "TOURNAMENT": return "турнир"
        case "GAME": return "игра"
        case "START": return "новички"
        case "MEDIUM": return "любители"
        case "HARD": return "профессионалы"
        case "WILL_BE": return "предстоит"
        case "UNDERWAY": return "в процессе"
        case "FINISHED": return "завершено"
        case "CANCELLED": return "отменено"
        case "DATE": return "по дате"
        case "COST": return "по стоимости"
        case "ASC": return "по возрастанию"
        case "DESC": return "по убыванию"
        default: return backendKey.lowercased()
        }
    }
    private func updateButtonAppearance(_ button: UIButton, isSelected: Bool) {
        var config = button.configuration ?? .filled()
        if isSelected {
            config.baseBackgroundColor = UIColor(named: "redColor")?.withAlphaComponent(0.2)
            config.baseForegroundColor = UIColor(named: "redColor")
            button.layer.borderWidth = 0
        } else {
            config.baseBackgroundColor = UIColor(named: "grayColor")?.withAlphaComponent(0.2)
            config.baseForegroundColor = UIColor(named: "redColor")
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        }
        button.configuration = config
        button.layer.cornerRadius = 14
        button.clipsToBounds = true
    }
    @objc private func sportChipTapped(_ sender: UIButton) {
        handleSingleSelection(sender, in: sportButtons) { self.currentFilters.sport = $0 }
    }
    @objc private func typeChipTapped(_ sender: UIButton) {
        handleSingleSelection(sender, in: typeButtons) { self.currentFilters.eventType = $0 }
    }
    @objc private func levelChipTapped(_ sender: UIButton) {
        handleSingleSelection(sender, in: levelButtons) { self.currentFilters.skillLevel = $0 }
    }
    @objc private func statusChipTapped(_ sender: UIButton) {
        handleSingleSelection(sender, in: statusButtons) { self.currentFilters.status = $0 }
    }
    @objc private func fieldChipTapped(_ sender: UIButton) {
        handleSingleSelection(sender, in: sortFieldButtons) { self.currentFilters.sortField = $0 }
    }
    @objc private func directionChipTapped(_ sender: UIButton) {
        handleSingleSelection(sender, in: sortDirectionButtons) { self.currentFilters.sortDirection = $0 }
    }
    private func handleSingleSelection(_ selectedButton: UIButton, in buttons: [UIButton], completion: (String?) -> Void) {
        let backendKey = selectedButton.accessibilityIdentifier
        let isAlreadySelected = selectedButton.configuration?.baseBackgroundColor == UIColor(named: "redColor")
        if isAlreadySelected {
            updateButtonAppearance(selectedButton, isSelected: false)
            completion(nil)
        } else {
            buttons.forEach { updateButtonAppearance($0, isSelected: ($0 == selectedButton)) }
            completion(backendKey)
        }
    }
    @objc private func resetButtonTapped() {
        currentFilters.sport = nil
        currentFilters.eventType = nil
        currentFilters.skillLevel = nil
        currentFilters.status = nil
        currentFilters.sortField = nil
        currentFilters.sortDirection = nil
        costStartField.text = nil
        costEndField.text = nil
        currentFilters.costStart = nil
        currentFilters.costEnd = nil
        dateStartField.text = nil
        dateEndField.text = nil
        currentFilters.dateStart = nil
        currentFilters.dateEnd = nil
        sportButtons.forEach { updateButtonAppearance($0, isSelected: false) }
        typeButtons.forEach { updateButtonAppearance($0, isSelected: false) }
        levelButtons.forEach { updateButtonAppearance($0, isSelected: false) }
        statusButtons.forEach { updateButtonAppearance($0, isSelected: false) }
        sortFieldButtons.forEach { updateButtonAppearance($0, isSelected: false) }
        sortDirectionButtons.forEach { updateButtonAppearance($0, isSelected: false) }
    }
    @objc private func applyButtonTapped() {
        currentFilters.costStart = Int(costStartField.text ?? "")
        currentFilters.costEnd = Int(costEndField.text ?? "")
        delegate?.didApplyFilters(currentFilters)
        dismiss(animated: true)
    }
}
