import UIKit

class SportsSelectionViewController: UIViewController {
    private let sports = ["Волейбол", "Алтимат", "Баскетбол", "Хоккей", "Футбол"]
    private let temporarySavedData: RegistrationRequest
    init(temporarySavedData: RegistrationRequest) {
        self.temporarySavedData = temporarySavedData
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("cat")
    }
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Выберите любимые виды спорта"
        label.numberOfLines = 2
        label.textColor = UIColor(named: "redColor")
        label.font = .Bold.title2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.allowsMultipleSelection = true
        collection.showsVerticalScrollIndicator = false
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    private lazy var registerButton: CustomButton = {
        let button = CustomButton(style: .firstType)
        button.setText("Зарегистрироваться")
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private lazy var backButton: CustomButton = {
        let button = CustomButton(style: .secondType)
        button.setText("Назад")
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.hidesBackButton = true
        registerButton.addTarget(self, action: #selector(performRegistration), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(tapBack), for: .touchUpInside)
        setupCollectionView()
        setupLayout()
    }
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SportCollectionViewCell.self, forCellWithReuseIdentifier: SportCollectionViewCell.identifier)
    }
    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(collectionView)
        view.addSubview(registerButton)
        view.addSubview(backButton)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 71),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            collectionView.bottomAnchor.constraint(equalTo: registerButton.topAnchor, constant: -20),
            backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            registerButton.bottomAnchor.constraint(equalTo: backButton.topAnchor, constant: -16),
            registerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            registerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    @objc func tapMain() {
        let mainVC = MainViewController()
        navigationController?.pushViewController(mainVC, animated: false)
    }
    @objc func tapBack() {
        navigationController?.popViewController(animated: false)
    }
    @objc private func performRegistration() {
        var selectedRussianSports: [String] = []
            if let selectedIndexPaths = collectionView.indexPathsForSelectedItems {
                for indexPath in selectedIndexPaths {
                selectedRussianSports.append(sports[indexPath.item])
            }
        }
        let backendSports = AuthNetworkService.shared.convertSportsToBackendFormat(selectedRussianSports)
        let finalRegistrationData = RegistrationRequest(
            name: temporarySavedData.name,
            nickname: temporarySavedData.nickname,
            email: temporarySavedData.email,
            password: temporarySavedData.password,
            favoriteSports: backendSports
        )
        AuthNetworkService.shared.register(requestModel: finalRegistrationData) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    TokenManager.shared.saveTokens(accessToken: response.accessToken, refreshToken: response.refreshToken)
                    let mainVC = MainTabBarController()
                    self?.navigationController?.pushViewController(mainVC, animated: false)
                case .failure(let error):
                    print("Ошибка регистрации: \(error.localizedDescription)")
                }
            }
        }
    }
}

extension SportsSelectionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sports.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SportCollectionViewCell.identifier,
            for: indexPath
        ) as? SportCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: sports[indexPath.item])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 12
        let collectionViewWidth = collectionView.frame.width
        let width = (collectionViewWidth - padding) / 2
        return CGSize(width: width, height: 56)
    }
}
