import UIKit

class DetailedViewController: UIViewController {
    
    private let eventId: String
    private var eventDetails: EventDetailModel?
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
    private let deadlineContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        return view
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
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Назад к мероприятиям", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .Bold.body
        button.backgroundColor = UIColor(named: "redColor") ?? .systemRed
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    init(eventId: String) {
        self.eventId = eventId
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
    private func loadData() {
        activityIndicator.startAnimating()
        scrollView.alpha = 0
        EventNetworkService.shared.fetchEventDetails(id: eventId) { [weak self] result in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            switch result {
            case .success(let details):
                self.eventDetails = details
                self.configureUI(with: details)
                UIView.animate(withDuration: 0.3) {
                    self.scrollView.alpha = 1
                }
            case .failure(let error):
                self.descriptionTextLabel.text = "Не удалось загрузить данные мероприятия."
                self.scrollView.alpha = 1
                print("Ошибка при получении деталей: \(error.localizedDescription)")
            }
        }
    }
    private func configureUI(with details: EventDetailModel) {
        titleLabel.text = details.name
        dateLabel.text = "Начало: \(details.visibleStartDate)\nКонец:  \(details.visibleEndDate)"
        deadlineDateLabel.text = details.visibleDeadline
        teamsValueLabel.text = details.visibleTeamsList
        costValueLabel.text = details.visibleCost
        firstRowTagsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        secondRowTagsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let statusPill = createPillBadge(
            text: details.visibleEventStatus,
            backgroundColor: (UIColor(named: "yellowColor")?.withAlphaComponent(0.2))!,
            textColor: UIColor(named: "yellowColor")!
        )
        let typePill = createPillBadge(
            text: details.visibleEventName,
            backgroundColor: (UIColor(named: "eventTypeColor")?.withAlphaComponent(0.2))!,
            textColor: UIColor(named: "eventTypeColor")!
        )
        let skillPill = createPillBadge(
            text: details.visibleSkillLevel,
            backgroundColor: (UIColor(named: "greenColor")?.withAlphaComponent(0.2))!,
            textColor: UIColor(named: "greenColor")!
        )
        let sportPill = createPillBadge(
            text: details.visibleSport,
            backgroundColor: (UIColor(named: "redColor")?.withAlphaComponent(0.2))!,
            textColor: UIColor(named: "redColor")!
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
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        tagsStackView.addArrangedSubview(spacer)
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
        view.addSubview(backButton)
        view.addSubview(activityIndicator)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        infoContainerView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        deadlineContainerView.addSubview(deadlineStackView)
        deadlineStackView.translatesAutoresizingMaskIntoConstraints = false
        deadlineStackView.addArrangedSubview(deadlineTitleLabel)
        deadlineStackView.addArrangedSubview(deadlineDateLabel)
        descriptionStackView.addArrangedSubview(descriptionTitleLabel)
        descriptionStackView.addArrangedSubview(descriptionTextLabel)
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
        contentStackView.addArrangedSubview(deadlineStackView)
        contentStackView.addArrangedSubview(teamsStackView)
        contentStackView.addArrangedSubview(costStackView)
        contentStackView.addArrangedSubview(authorStackView)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            backButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            backButton.heightAnchor.constraint(equalToConstant: 50),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 58),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            scrollView.bottomAnchor.constraint(equalTo: backButton.topAnchor, constant: -16),
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
}
