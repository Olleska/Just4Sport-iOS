import UIKit
import PhotosUI

final class EditProfileViewController: UIViewController {
    
    private let initialName: String
    private let initialNickname: String
    private let initialEmail: String
    private let initialFavoriteSports: [String]
    private var selectedSports: [String] = []
    private let allSports: [SportType] = SportType.allCases
    private let initialPhotoPath: String?
    var onSaveSuccess: (() -> Void)?
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        scroll.keyboardDismissMode = .onDrag
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemGray5
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
        imageView.addGestureRecognizer(tap)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var changePhotoLabel: UILabel = {
        let label = UILabel()
        label.text = "Изменить фото"
        label.font = .Bold.body
        label.textColor = UIColor(named: "redColor") ?? .systemRed
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
        label.addGestureRecognizer(tap)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var avatarContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var nameTextField = EditProfileViewController.makeTextField(placeholder: "Имя")
    private lazy var nicknameTextField = EditProfileViewController.makeTextField(placeholder: "Никнейм")
    private lazy var emailTextField = EditProfileViewController.makeTextField(placeholder: "Email", keyboardType: .emailAddress)
    
    private lazy var tagsCollectionView: UICollectionView = {
        let layout = LeftAlignedFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        collectionView.register(SportTagCell.self, forCellWithReuseIdentifier: SportTagCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Сохранить изменения", for: .normal)
        button.titleLabel?.font = .Bold.body
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "redColor") ?? .systemRed
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private lazy var deleteAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Удалить профиль", for: .normal)
        button.titleLabel?.font = .Bold.body
        button.setTitleColor(UIColor(named: "redColor") ?? .systemRed, for: .normal)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(deleteAccountButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Назад", for: .normal)
        button.titleLabel?.font = .Bold.body
        button.setTitleColor(UIColor(named: "redColor") ?? .systemRed, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = (UIColor(named: "redColor") ?? .systemRed).cgColor
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(name: String, nickname: String, email: String, favoriteSports: [String], photoPath: String?) {
        self.initialName = name
        self.initialNickname = nickname
        self.initialEmail = email
        self.initialFavoriteSports = favoriteSports
        self.selectedSports = favoriteSports
        self.initialPhotoPath = photoPath
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("сat")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.hidesBackButton = true
        
        setupLayout()
        fillCurrentData()
        setupKeyboardDismissRecognizer()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let height = tagsCollectionView.collectionViewLayout.collectionViewContentSize.height
        if let heightConstraint = tagsCollectionView.constraints.first(where: { $0.firstAttribute == .height }) {
            heightConstraint.constant = max(height, 45)
        } else {
            tagsCollectionView.heightAnchor.constraint(equalToConstant: max(height, 45)).isActive = true
        }
    }
    
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        avatarContainerView.addSubview(avatarImageView)
        avatarContainerView.addSubview(changePhotoLabel)
        contentStackView.addArrangedSubview(avatarContainerView)
        contentStackView.addArrangedSubview(createFormRow(title: "Имя", inputView: nameTextField))
        contentStackView.addArrangedSubview(createFormRow(title: "Никнейм", inputView: nicknameTextField))
        contentStackView.addArrangedSubview(createFormRow(title: "Email", inputView: emailTextField))
        contentStackView.addArrangedSubview(createFormRow(title: "Любимые виды спорта", inputView: tagsCollectionView))
        contentStackView.setCustomSpacing(32, after: tagsCollectionView.superview ?? tagsCollectionView)
        contentStackView.addArrangedSubview(saveButton)
        contentStackView.setCustomSpacing(12, after: saveButton)
        contentStackView.addArrangedSubview(backButton)
        contentStackView.setCustomSpacing(24, after: backButton)
        contentStackView.addArrangedSubview(deleteAccountButton)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            avatarContainerView.heightAnchor.constraint(equalToConstant: 150),
            avatarImageView.topAnchor.constraint(equalTo: avatarContainerView.topAnchor),
            avatarImageView.centerXAnchor.constraint(equalTo: avatarContainerView.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 120),
            avatarImageView.heightAnchor.constraint(equalToConstant: 120),
            changePhotoLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 6),
            changePhotoLabel.centerXAnchor.constraint(equalTo: avatarContainerView.centerXAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 48),
            backButton.heightAnchor.constraint(equalToConstant: 48),
            deleteAccountButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    private func fillCurrentData() {
        nameTextField.text = initialName
        nicknameTextField.text = initialNickname
        emailTextField.text = initialEmail
        if let photoPath = initialPhotoPath {
            avatarImageView.loadImage(from: photoPath, placeholder: UIImage(named: "imageProfile"))
        } else {
            avatarImageView.image = UIImage(named: "imageProfile")
            avatarImageView.tintColor = .systemGray4
        }
        tagsCollectionView.reloadData()
    }
    @objc private func avatarTapped() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    @objc private func saveButtonTapped() {
        let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let nickname = nicknameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if name.isEmpty || nickname.isEmpty || email.isEmpty {
            showErrorAlert(message: "Пожалуйста, заполните все поля.")
            return
        }
        guard let token = TokenManager.shared.getAccessToken() else {
            showErrorAlert(message: "Ошибка авторизации. Токен не найден.")
            return
        }
        saveButton.isEnabled = false
        let updateModel = UpdateProfileRequest(
            name: name,
            nickname: nickname,
            email: email,
            favoriteSports: selectedSports
        )
        let networkService = ProfileNetworkService()
        networkService.updateProfile(accessToken: token, body: updateModel) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.saveButton.isEnabled = true
                switch result {
                case .success:
                    print("Профиль успешно обновлен на бэкенде!")
                    self.onSaveSuccess?()
                    self.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    print("Ошибка при сохранении: \(error.localizedDescription)")
                    self.showErrorAlert(message: "Не удалось сохранить изменения: \(error.localizedDescription)")
                }
            }
        }
    }
    @objc private func deleteAccountButtonTapped() {
        let alert = UIAlertController(
            title: "Удаление профиля",
            message: "Вы уверены, что хотите удалить свой профиль? Это действие необратимо.",
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.performDeleteAccount()
        }
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        present(alert, animated: true)
    }
    private func performDeleteAccount() {
        guard let token = TokenManager.shared.getAccessToken() else {
            showErrorAlert(message: "Ошибка авторизации. Токен не найден.")
            return
        }
        deleteAccountButton.isEnabled = false
        let networkService = ProfileNetworkService()
        networkService.deleteProfile(accessToken: token) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.deleteAccountButton.isEnabled = true
                
                switch result {
                case .success:
                    print("Профиль успешно удален.")
                    TokenManager.shared.clearTokens()
                    self.navigateToLoginScreen()
                case .failure(let error):
                    print("Ошибка при удалении аккаунта: \(error.localizedDescription)")
                    self.showErrorAlert(message: "Не удалось удалить профиль: \(error.localizedDescription)")
                }
            }
        }
    }
    private func navigateToLoginScreen() {
        navigationController?.popToRootViewController(animated: true)
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
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
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
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
}

extension EditProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allSports.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SportTagCell.identifier, for: indexPath) as? SportTagCell else {
            return UICollectionViewCell()
        }
        let sport = allSports[indexPath.item]
        cell.configure(with: sport.visibleName)
        let isSelected = selectedSports.contains(sport.rawValue)
        if isSelected {
            cell.contentView.backgroundColor = UIColor(named: "redColor")?.withAlphaComponent(0.2) ?? .systemRed.withAlphaComponent(0.15)
        } else {
            cell.contentView.backgroundColor = .systemGray6
        }
        cell.layer.cornerRadius = 14
        cell.clipsToBounds = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sport = allSports[indexPath.item]
        if let index = selectedSports.firstIndex(of: sport.rawValue) {
            selectedSports.remove(at: index)
        } else {
            selectedSports.append(sport.rawValue)
        }
        collectionView.reloadData()
    }
}

extension EditProfileViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
        provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            guard let self = self, let uiImage = image as? UIImage else { return }
            guard let imageData = uiImage.jpegData(compressionQuality: 0.7) else { return }
            DispatchQueue.main.async {
                self.avatarImageView.image = uiImage
            }
            guard let token = TokenManager.shared.getAccessToken() else { return }
            let networkService = ProfileNetworkService()
            networkService.uploadProfilePhoto(accessToken: token, imageRawData: imageData) { result in
                switch result {
                case .success:
                    print("Фото профиля успешно загружено на бэкенд!")
                case .failure(let error):
                    print("Ошибка отправки фото на бэкенд: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.showErrorAlert(message: "Не удалось сохранить фото на сервере.")
                    }
                }
            }
        }
    }
}
