import UIKit

class MainViewController: UIViewController {
    private var currentPage = 0
    private var isLoading = false
    private var isLastPage = false
    private var filterParameters = EventFilterParameters()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "JUST 4SPORT"
        label.font = .Bold.title2
        label.textColor = UIColor(named: "redColor")
        return label
    }()
    private lazy var searchField: UITextField = {
        let text = UITextField()
        text.font = .Regular.body
        text.placeholder = "Поиск мероприятий"
        text.backgroundColor = UIColor(named: "grayColor")?.withAlphaComponent(0.2)
        text.layer.cornerRadius = 8
        text.layer.borderWidth = 0
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        text.leftView = paddingView
        text.leftViewMode = .always
        text.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
        return text
    }()
    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        //button.setTitle("Фильтр", for: .normal)
        button.setImage(UIImage(named: "penImage"), for: .normal)
        button.tintColor = .white
        button.titleLabel?.font = .Bold.body
        button.backgroundColor = UIColor(named: "redColor")
        button.layer.cornerRadius = 16
        button.contentHorizontalAlignment = .center // Центрируем контент по горизонтали
        button.contentVerticalAlignment = .center   // Центрируем контент по вертикали
        button.contentEdgeInsets = .zero
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        return scroll
    }()
    private lazy var cardsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        view.backgroundColor = .white
        setup()
        scrollView.delegate = self
        loadNextPage()
    }
    private func setup() {
        view.addSubview(titleLabel)
        view.addSubview(searchField)
        view.addSubview(filterButton)
        view.addSubview(scrollView)
        scrollView.addSubview(cardsStackView)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        searchField.translatesAutoresizingMaskIntoConstraints = false
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        cardsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 75),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            searchField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            searchField.widthAnchor.constraint(equalToConstant: 270),
            searchField.heightAnchor.constraint(equalToConstant: 44),
            filterButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            filterButton.leadingAnchor.constraint(equalTo: searchField.trailingAnchor, constant: 10),
            filterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            filterButton.heightAnchor.constraint(equalToConstant: 44),
            scrollView.topAnchor.constraint(equalTo: filterButton.bottomAnchor, constant: 12),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            cardsStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            cardsStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            cardsStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            cardsStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            cardsStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }
    @objc private func searchTextChanged() {
        filterParameters.name = searchField.text?.isEmpty == false ? searchField.text : nil
        resetAndReload()
    }
    private func resetAndReload() {
        currentPage = 0
        isLastPage = false
        cardsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        loadNextPage()
    }
    @objc private func filterButtonTapped() {
        let filterVC = FilterViewController(currentFilters: filterParameters)
        filterVC.delegate = self
        if let sheet = filterVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(filterVC, animated: true)
    }
    private func loadNextPage() {
        guard !isLoading && !isLastPage else { return }
        isLoading = true
        EventNetworkService.shared.fetchEvents(page: currentPage, filters: filterParameters) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success(let response):
                self.isLastPage = response.last
                self.appendNewCards(response.content)
                self.currentPage += 1
            case .failure(let error):
                print("Ошибка при получении мероприятий: \(error.localizedDescription)")
            }
        }
    }
    private func appendNewCards(_ newEvents: [EventModel]) {
        for event in newEvents {
            let card = EventCardComponent()
            let imageUrlString = event.photo?.fullUrlString
            card.configure(
                title: event.name,
                start: event.visibleStartDate,
                end: event.visibleEndDate,
                type: event.visibleEventName,
                level: event.visibleSkillLevel,
                sport: event.visibleSport,
                status: event.visibleEventStatus,
                imageUrlString: imageUrlString
            )
            card.onDetailsTap = { [weak self] in
                guard let self = self else { return }
                let detailedVC = DetailedViewController(eventId: event.id)
                self.navigationController?.pushViewController(detailedVC, animated: true)
            }
            cardsStackView.addArrangedSubview(card)
        }
    }
}

extension MainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        if offsetY > contentHeight - frameHeight - 100 {
            loadNextPage()
        }
    }
}

extension MainViewController: FilterViewControllerDelegate {
    func didApplyFilters(_ filters: EventFilterParameters) {
        self.filterParameters.sport = filters.sport
        self.filterParameters.eventType = filters.eventType
        self.filterParameters.skillLevel = filters.skillLevel
        self.filterParameters.status = filters.status
        self.filterParameters.sortField = filters.sortField
        self.filterParameters.sortDirection = filters.sortDirection
        self.filterParameters.costStart = filters.costStart
        self.filterParameters.costEnd = filters.costEnd
        self.filterParameters.dateStart = filters.dateStart
        self.filterParameters.dateEnd = filters.dateEnd
        resetAndReload()
    }
}

extension UIImageView {
    func loadImage(from urlString: String?, placeholder: UIImage? = nil) {
        self.image = placeholder
        guard let urlString = urlString, let url = URL(string: urlString) else {
            print("Некорректная строка URL: \(urlString ?? "nil")")
            return
        }
        let currentUrlString = urlString
        self.accessibilityIdentifier = currentUrlString
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = TokenManager.shared.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            if let error = error {
                print("Ошибка сети при загрузке картинки: \(error.localizedDescription)")
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                if !(200...299).contains(httpResponse.statusCode) {
                    print("Сервер вернул код ошибки \(httpResponse.statusCode) для URL: \(urlString)")
                    return
                }
            }
            guard let data = data, let downloadedImage = UIImage(data: data) else {
                if let text = String(data: data ?? Data(), encoding: .utf8) {
                    print("Текст ответа сервера (первые 100 символов): \(String(text.prefix(100)))")
                }
                return
            }
            DispatchQueue.main.async {
                if self.accessibilityIdentifier == currentUrlString {
                    self.image = downloadedImage
                    self.backgroundColor = .clear
                }
            }
        }.resume()
    }
}
