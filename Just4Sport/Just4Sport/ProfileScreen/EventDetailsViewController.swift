import UIKit

final class EventDetailsViewController: UIViewController {
    private let eventId: String
    private let role: EventRole
    private let currentUserNickname: String
    private var eventDetails: EventDetailModel?
    private var isCaptain: Bool = false
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = UIColor(named: "redColor") ?? .systemRed
        indicator.hidesWhenStopped = true
        return indicator
    }()
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        return scroll
    }()
    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.distribution = .fill
        return stack
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .Bold.title2
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    private let infoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "redColor")?.withAlphaComponent(0.2) ?? .systemGray6
        view.layer.cornerRadius = 16
        return view
    }()
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .SemiBold.body
        label.textColor = UIColor(named: "redColor")
        label.numberOfLines = 0
        return label
    }()
    private let tagsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .fill
        return stack
    }()
    private let firstRowTagsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()
    private let secondRowTagsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()
    private let descriptionStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    private let descriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "О мероприятии"
        label.font = .Bold.title3
        label.textColor = .black
        return label
    }()
    private let descriptionTextLabel: UILabel = {
        let label = UILabel()
        label.font = .Regular.body
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    private let authorStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    private let authorTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Организатор"
        label.font = .Bold.title3
        label.textColor = .black
        return label
    }()
    private let authorNameLabel: UILabel = {
        let label = UILabel()
        label.font = .Regular.body
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    private let deadlineStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.backgroundColor = UIColor(named: "grayColor")?.withAlphaComponent(0.2) ?? .systemRed.withAlphaComponent(0.12)
        stack.layer.cornerRadius = 16
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 24)
        return stack
    }()
    private let deadlineTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Дедлайн подачи заявки"
        label.font = .Regular.body
        label.textColor = UIColor(named: "redColor") ?? .systemRed
        return label
    }()
    private let deadlineDateLabel: UILabel = {
        let label = UILabel()
        label.font = .Bold.title3
        label.textColor = UIColor(named: "redColor") ?? .systemRed
        return label
    }()
    private let teamsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    private let teamsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Участвующие команды"
        label.font = .Bold.title3
        label.textColor = .black
        return label
    }()
    private let teamsValueLabel: UILabel = {
        let label = UILabel()
        label.font = .Regular.body
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    private let costStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    private let costTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Стоимость участия"
        label.font = .Bold.title3
        label.textColor = .black
        return label
    }()
    private let costValueLabel: UILabel = {
        let label = UILabel()
        label.font = .Regular.body
        label.textColor = .black
        return label
    }()
    private let placeStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    private let placeTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Место проведения"
        label.font = .Bold.title3
        label.textColor = .black
        return label
    }()
    private let placeValueLabel: UILabel = {
        let label = UILabel()
        label.font = .Regular.body
        label.textColor = .black
        return label
    }()
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Назад в профиль", for: .normal)
        let grayColor = UIColor(named: "grayColor")
        let redColor = UIColor(named: "redColor")
        button.setTitleColor(redColor, for: .normal)
        button.titleLabel?.font = .Bold.body
        button.backgroundColor = grayColor?.withAlphaComponent(0.2)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelApplicationButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .Bold.body
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(cancelApplicationTapped), for: .touchUpInside)
        return button
    }()
    private lazy var actionButton: UIButton = cancelApplicationButton
    init(eventId: String, role: EventRole, currentUserNickname: String) {
        self.eventId = eventId
        self.role = role
        self.currentUserNickname = currentUserNickname
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("cat")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        loadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    private func configureActionButtonsByRole() {
        switch role {
        case .author:
            actionButton.setTitle("Управлять мероприятием", for: .normal)
            actionButton.backgroundColor = UIColor(named: "redColor") ?? .systemRed
            actionButton.tintColor = .white
            actionButton.isHidden = false
            actionButton.isUserInteractionEnabled = true
        case .participant:
            if isCaptain {
                actionButton.setTitle("Отозвать заявку команды", for: .normal)
                actionButton.tintColor = .white
                actionButton.backgroundColor = UIColor(named: "redColor") ?? .systemRed
                actionButton.isHidden = false
                actionButton.isUserInteractionEnabled = true
            } else {
                actionButton.setTitle("Вы участвуете в мероприятии", for: .normal)
                actionButton.tintColor = UIColor(named: "redColor") ?? .systemRed
                actionButton.backgroundColor = UIColor(named: "redColor")?.withAlphaComponent(0.2) ?? .systemRed
                actionButton.isHidden = false
                actionButton.isUserInteractionEnabled = false
            }
        }
    }
    private func loadData() {
        activityIndicator.startAnimating()
        scrollView.alpha = 0
        EventNetworkService.shared.fetchEventDetails(id: eventId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.activityIndicator.stopAnimating()
                switch result {
                case .success(let details):
                    self.eventDetails = details
                    self.configureUI(with: details)
                    var userIsCaptainOfAnyTeam = false
                    var teamsStringBuilder = ""
                    let teams = details.teams
                    if !teams.isEmpty {
                        for team in teams {
                            teamsStringBuilder += "\(team.name)"
                            teamsStringBuilder += "\n"
                        }
                        
                        let finalFormat = teamsStringBuilder.trimmingCharacters(in: .whitespacesAndNewlines)
                        self.teamsValueLabel.text = finalFormat
                    } else {
                        self.teamsValueLabel.text = "Команд пока нет"
                    }
                    self.isCaptain = userIsCaptainOfAnyTeam
                    self.configureActionButtonsByRole()
                    
                    UIView.animate(withDuration: 0.3) {
                        self.scrollView.alpha = 1
                    }
                    
                case .failure(let error):
                    self.descriptionTextLabel.text = "Не удалось загрузить данные мероприятия."
                    self.scrollView.alpha = 1
                    print("Ошибка при получении деталей в профиле: \(error.localizedDescription)")
                }
            }
        }
    }
    @objc private func cancelApplicationTapped() {
        switch role {
        case .author:
            openManagementScreen()
        case .participant:
            if isCaptain {
                showCancelApplicationAlert()
            }
        }
    }
    private func showCancelApplicationAlert() {
        let alert = UIAlertController(
            title: "Отзыв заявки",
            message: "Вы уверены, что хотите отозвать заявку вашей команды на участие?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Да, отозвать", style: .destructive) { [weak self] _ in
            self?.performDeleteApplicationRequest()
        })
        present(alert, animated: true)
    }
    private func openManagementScreen() {
        guard let eventDetails = eventDetails else {
            return
        }
        let editVC = EditEventViewController(eventId: eventId, eventDetails: eventDetails)
        navigationController?.pushViewController(editVC, animated: true)
    }
    private func configureUI(with details: EventDetailModel) {
        titleLabel.text = details.name
        dateLabel.text = "Начало: \(details.visibleStartDate)\nКонец:  \(details.visibleEndDate)"
        deadlineDateLabel.text = details.visibleDeadline
        costValueLabel.text = details.visibleCost
        placeValueLabel.text = details.place
        teamsValueLabel.text = details.visibleTeamsList
        firstRowTagsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        secondRowTagsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let statusPill = createPillBadge(
            text: details.visibleEventStatus,
            backgroundColor: UIColor(named: "yellowColor")?.withAlphaComponent(0.2) ?? .systemYellow.withAlphaComponent(0.2),
            textColor: UIColor(named: "yellowColor") ?? .systemYellow
        )
        let typePill = createPillBadge(
            text: details.visibleEventName,
            backgroundColor: UIColor(named: "eventTypeColor")?.withAlphaComponent(0.2) ?? .systemBlue.withAlphaComponent(0.2),
            textColor: UIColor(named: "eventTypeColor") ?? .systemBlue
        )
        let skillPill = createPillBadge(
            text: details.visibleSkillLevel,
            backgroundColor: UIColor(named: "greenColor")?.withAlphaComponent(0.2) ?? .systemGreen.withAlphaComponent(0.2),
            textColor: UIColor(named: "greenColor") ?? .systemGreen
        )
        let sportPill = createPillBadge(
            text: details.visibleSport,
            backgroundColor: UIColor(named: "redColor")?.withAlphaComponent(0.2) ?? .systemRed.withAlphaComponent(0.2),
            textColor: UIColor(named: "redColor") ?? .systemRed
        )
        firstRowTagsStackView.addArrangedSubview(statusPill)
        let spacer1 = UIView()
        spacer1.setContentHuggingPriority(.defaultLow, for: .horizontal)
        firstRowTagsStackView.addArrangedSubview(spacer1)
        secondRowTagsStackView.addArrangedSubview(typePill)
        secondRowTagsStackView.addArrangedSubview(skillPill)
        secondRowTagsStackView.addArrangedSubview(sportPill)
        let spacer2 = UIView()
        spacer2.setContentHuggingPriority(.defaultLow, for: .horizontal)
        secondRowTagsStackView.addArrangedSubview(spacer2)
        if let desc = details.description, !desc.isEmpty {
            descriptionTextLabel.text = desc
        } else {
            descriptionTextLabel.text = "Организатор не добавил описание к этому мероприятию."
        }
        let authorName = details.author?.name ?? "Неизвестный организатор"
        if let nickname = details.author?.nickname, !nickname.isEmpty {
            authorNameLabel.text = "\(authorName) (@\(nickname))"
        } else {
            authorNameLabel.text = authorName
        }
    }
    private func createPillBadge(text: String, backgroundColor: UIColor, textColor: UIColor) -> UIView {
        let container = UIView()
        container.backgroundColor = backgroundColor
        container.layer.cornerRadius = 10
        container.clipsToBounds = true
        let label = UILabel()
        label.text = text
        label.font = .Regular.body
        label.textColor = textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12)
        ])
        return container
    }
    private func setupLayout() {
        view.addSubview(scrollView)
        view.addSubview(activityIndicator)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        infoContainerView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        deadlineStackView.addArrangedSubview(deadlineTitleLabel)
        deadlineStackView.addArrangedSubview(deadlineDateLabel)
        descriptionStackView.addArrangedSubview(descriptionTitleLabel)
        descriptionStackView.addArrangedSubview(descriptionTextLabel)
        placeStackView.addArrangedSubview(placeTitleLabel)
        placeStackView.addArrangedSubview(placeValueLabel)
        teamsStackView.addArrangedSubview(teamsTitleLabel)
        teamsStackView.addArrangedSubview(teamsValueLabel)
        costStackView.addArrangedSubview(costTitleLabel)
        costStackView.addArrangedSubview(costValueLabel)
        authorStackView.addArrangedSubview(authorTitleLabel)
        authorStackView.addArrangedSubview(authorNameLabel)
        tagsStackView.addArrangedSubview(firstRowTagsStackView)
        tagsStackView.addArrangedSubview(secondRowTagsStackView)
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(tagsStackView)
        contentStackView.addArrangedSubview(infoContainerView)
        contentStackView.addArrangedSubview(descriptionStackView)
        contentStackView.addArrangedSubview(placeStackView)
        contentStackView.addArrangedSubview(deadlineStackView)
        contentStackView.addArrangedSubview(costStackView)
        contentStackView.addArrangedSubview(authorStackView)
        contentStackView.addArrangedSubview(teamsStackView)
        contentStackView.addArrangedSubview(cancelApplicationButton)
        contentStackView.addArrangedSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        cancelApplicationButton.translatesAutoresizingMaskIntoConstraints = false
        let cancelHeightConstraint = cancelApplicationButton.heightAnchor.constraint(equalToConstant: 44)
        cancelHeightConstraint.priority = .defaultHigh
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            backButton.heightAnchor.constraint(equalToConstant: 44),
            cancelHeightConstraint,
            
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 58),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: infoContainerView.topAnchor, constant: 16),
            dateLabel.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor, constant: -16),
            dateLabel.bottomAnchor.constraint(equalTo: infoContainerView.bottomAnchor, constant: -16)
        ])
    }
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    private func performDeleteApplicationRequest() {
        cancelApplicationButton.isEnabled = false
        activityIndicator.startAnimating()
        print("Вызов запроса для удаления заявки на ивент: \(eventId)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.cancelApplicationButton.isEnabled = true
            self?.navigationController?.popViewController(animated: true)
        }
    }
}
