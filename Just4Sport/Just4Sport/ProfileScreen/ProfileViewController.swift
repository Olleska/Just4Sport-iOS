import UIKit

final class ProfileViewController: UIViewController {
    
    private var sportsTags: [String] = ["Волейбол", "Баскетбол", "Алтимат", "Хоккей"]
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
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        loadProfileData()
    }
    private func setupLayout() {
        view.addSubview(headerStackView)
        view.addSubview(profileInfoStackView)
        view.addSubview(tagsCollectionView)
        NSLayoutConstraint.activate([
            headerStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 67),
            headerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            headerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            profileInfoStackView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 24),
            profileInfoStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            profileInfoStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            avatarImageView.widthAnchor.constraint(equalToConstant: 120),
            avatarImageView.heightAnchor.constraint(equalToConstant: 120),
            tagsCollectionView.topAnchor.constraint(equalTo: profileInfoStackView.bottomAnchor, constant: 24),
            tagsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            tagsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            tagsCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
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
                self?.nameLabel.text = profile.name
                self?.nicknameLabel.text = profile.nickname
                self?.emailLabel.text = profile.email
                self?.sportsTags = profile.favoriteSports.map { sportRawValue in
                    return SportType(rawValue: sportRawValue)?.visibleName ?? sportRawValue
                }
                //self?.avatarImageView.image = profile.photo
                self?.tagsCollectionView.reloadData()
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
        return sportsTags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SportTagCell.identifier, for: indexPath) as? SportTagCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: sportsTags[indexPath.item])
        return cell
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

