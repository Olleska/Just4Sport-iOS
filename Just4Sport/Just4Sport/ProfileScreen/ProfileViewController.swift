import UIKit

final class ProfileViewController: UIViewController {
    private var currentProfileRawData: ProfileResponse?
    private var sportsTags: [String] = []
    private var authorEvents: [ProfileEvent] = []
    private var participantEvents: [ProfileEvent] = []
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "JUST 4SPORT"
        label.font = .Bold.title2
        label.textColor = UIColor(named: "redColor")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "penImage")
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(named: "redColor")
        button.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private lazy var headerStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, editButton])
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemGray5 
        imageView.layer.cornerRadius = 16      
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .SemiBold.title1
        label.textColor = UIColor(named: "redColor")
        return label
    }()
    private lazy var nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = .Regular.callout
        label.textColor = UIColor(named: "redColor")
        return label
    }()
    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.font = .Regular.callout
        label.textColor = UIColor(named: "redColor")
        return label
    }()
    private lazy var profileTextStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [nameLabel, nicknameLabel, emailLabel])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .leading
        return stack
    }()
    private lazy var profileInfoStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [avatarImageView, profileTextStackView])
        stack.axis = .horizontal
        stack.spacing = 20
        stack.alignment = .top
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    private lazy var tagsCollectionView: UICollectionView = {
        let layout = LeftAlignedFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(SportTagCell.self, forCellWithReuseIdentifier: SportTagCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    private lazy var authorSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "Организатор"
        label.font = .Bold.title3
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var authorCollectionView: UICollectionView = createHorizontalCollectionView()
    private lazy var participantSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "Участник"
        label.font = .Bold.title3
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var participantCollectionView: UICollectionView = createHorizontalCollectionView()
    private func createHorizontalCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 12
        layout.itemSize = CGSize(width: 235, height: 140)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.dataSource = self
        cv.delegate = self
        cv.register(ProfileEventCell.self, forCellWithReuseIdentifier: ProfileEventCell.identifier)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Выйти из аккаунта", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .Bold.body
        button.backgroundColor = (UIColor(named: "redColor") ?? .systemRed)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        loadProfileData()
    }
    private func setupLayout() {
        view.addSubview(headerStackView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(profileInfoStackView)
        contentView.addSubview(tagsCollectionView)
        contentView.addSubview(authorSectionLabel)
        contentView.addSubview(authorCollectionView)
        contentView.addSubview(participantSectionLabel)
        contentView.addSubview(participantCollectionView)
        contentView.addSubview(logoutButton)
        NSLayoutConstraint.activate([
            headerStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 67),
            headerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            headerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            scrollView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            profileInfoStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            profileInfoStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            profileInfoStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            avatarImageView.widthAnchor.constraint(equalToConstant: 120),
            avatarImageView.heightAnchor.constraint(equalToConstant: 120),
            tagsCollectionView.topAnchor.constraint(equalTo: profileInfoStackView.bottomAnchor, constant: 24),
            tagsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            tagsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            tagsCollectionView.heightAnchor.constraint(equalToConstant: 45),
            authorSectionLabel.topAnchor.constraint(equalTo: tagsCollectionView.bottomAnchor, constant: 32),
            authorSectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            authorCollectionView.topAnchor.constraint(equalTo: authorSectionLabel.bottomAnchor, constant: 12),
            authorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            authorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            authorCollectionView.heightAnchor.constraint(equalToConstant: 140),
            participantSectionLabel.topAnchor.constraint(equalTo: authorCollectionView.bottomAnchor, constant: 32),
            participantSectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            participantCollectionView.topAnchor.constraint(equalTo: participantSectionLabel.bottomAnchor, constant: 12),
            participantCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            participantCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            participantCollectionView.heightAnchor.constraint(equalToConstant: 140),
            logoutButton.topAnchor.constraint(equalTo: participantCollectionView.bottomAnchor, constant: 40),
            logoutButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            logoutButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            logoutButton.heightAnchor.constraint(equalToConstant: 50),
            logoutButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }
    @objc private func logoutTapped() {
        guard let accessToken = TokenManager.shared.getAccessToken() else {
            self.switchToLoginScreen()
            return
        }
        let tempRefreshToken = accessToken
        let networkService = ProfileNetworkService()
        logoutButton.isEnabled = false
        networkService.logout(accessToken: accessToken, refreshToken: tempRefreshToken) { [weak self] result in
            DispatchQueue.main.async {
                self?.logoutButton.isEnabled = true
                switch result {
                case .success:
                    print("Успешный выход на бэкенде")
                    TokenManager.shared.clearTokens()
                    self?.switchToLoginScreen()
                case .failure(let error):
                    print("Ошибка при выходе: \(error.localizedDescription)")
                    TokenManager.shared.clearTokens()
                    self?.switchToLoginScreen()
                }
            }
        }
    }
    private func switchToLoginScreen() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        let registerVC = RegisterViewController()
        let navigationController = UINavigationController(rootViewController: registerVC)
        window.rootViewController = navigationController
        UIView.transition(with: window,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
    }
    @objc private func editButtonTapped() {
        guard let profileData = currentProfileRawData else { return }
        let editVC = EditProfileViewController(
            userId: profileData.id!,
            name: profileData.name,
            nickname: profileData.nickname,
            email: profileData.email,
            favoriteSports: profileData.favoriteSports
        )
        editVC.onSaveSuccess = { [weak self] in
            self?.loadProfileData()
        }
        navigationController?.pushViewController(editVC, animated: true)
    }
    private func loadProfileData() {
        guard let token = TokenManager.shared.getAccessToken() else {
            print("Пользователь не авторизован: токен отсутствует в памяти")
            return
        }
        let networkService = ProfileNetworkService()
        networkService.fetchProfile(accessToken: token) { [weak self] result in
            switch result {
            case .success(let profile):
                self?.currentProfileRawData = profile
                self?.nameLabel.text = profile.name
                self?.nicknameLabel.text = profile.nickname
                self?.emailLabel.text = profile.email
                self?.sportsTags = profile.favoriteSports.map { sportRawValue in
                    return SportType(rawValue: sportRawValue)?.visibleName ?? sportRawValue
                }
                //self?.avatarImageView.image = profile.photo
                self?.tagsCollectionView.reloadData()
                self?.authorEvents = profile.authorEvents
                self?.participantEvents = profile.participantEvents
                self?.tagsCollectionView.reloadData()
                self?.authorCollectionView.reloadData()
                self?.participantCollectionView.reloadData()
            case .failure(let error):
                print("Ошибка загрузки профиля: \(error.localizedDescription)")
                let alert = UIAlertController(
                    title: "Ошибка",
                    message: "Не удалось загрузить данные профиля: \(error.localizedDescription)",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "ОК", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }
}

extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == tagsCollectionView {
            return sportsTags.count
        } else if collectionView == authorCollectionView {
            return authorEvents.count
        } else if collectionView == participantCollectionView {
            return participantEvents.count
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == tagsCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SportTagCell.identifier, for: indexPath) as? SportTagCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: sportsTags[indexPath.item])
            return cell
        }
        if collectionView == authorCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileEventCell.identifier, for: indexPath) as? ProfileEventCell else {
                return UICollectionViewCell()
            }
            let event = authorEvents[indexPath.item]
            cell.configure(with: event)
            return cell
        }
        if collectionView == participantCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileEventCell.identifier, for: indexPath) as? ProfileEventCell else {
                return UICollectionViewCell()
            }
            let event = participantEvents[indexPath.item]
            cell.configure(with: event)
            return cell
        }
        return UICollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == tagsCollectionView { return }
        let selectedEvent: ProfileEvent
        let userRole: EventRole
        if collectionView == authorCollectionView {
            selectedEvent = authorEvents[indexPath.item]
            userRole = .author
        } else if collectionView == participantCollectionView {
            selectedEvent = participantEvents[indexPath.item]
            userRole = .participant
        } else {
            return
        }
        let detailsVC = EventDetailsViewController(eventId: selectedEvent.id, role: userRole)
        if let navigationController = self.navigationController {
            navigationController.pushViewController(detailsVC, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: detailsVC)
            self.present(nav, animated: true)
        }
    }
}

class LeftAlignedFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.representedElementCategory == .cell {
                if layoutAttribute.frame.origin.y >= maxY {
                    leftMargin = sectionInset.left
                }
                layoutAttribute.frame.origin.x = leftMargin
                leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
                maxY = max(layoutAttribute.frame.maxY, maxY)
            }
        }
        return attributes
    }
}


