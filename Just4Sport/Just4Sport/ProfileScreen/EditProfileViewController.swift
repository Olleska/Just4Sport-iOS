import UIKit

final class EditProfileViewController: UIViewController {
    var onSaveSuccess: (() -> Void)?
    private let userId: String
    private let currentName: String
    private let currentNickname: String
    private let currentEmail: String
    private let favoriteSports: [String]
    private lazy var nameTextField: UITextField = createTextField(placeholder: "Имя", text: currentName)
    private lazy var nicknameTextField: UITextField = createTextField(placeholder: "Никнейм", text: currentNickname)
    private lazy var emailTextField: UITextField = createTextField(placeholder: "Email", text: currentEmail)
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Сохранить", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .Bold.body
        button.backgroundColor = UIColor(named: "redColor") ?? .systemRed
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        return button
    }()
    init(userId: String, name: String, nickname: String, email: String, favoriteSports: [String]) {
        self.userId = userId
        self.currentName = name
        self.currentNickname = nickname
        self.currentEmail = email
        self.favoriteSports = favoriteSports
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("cat")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Редактирование профиля"
        setupLayout()
    }
    private func setupLayout() {
        let stackView = UIStackView(arrangedSubviews: [nameTextField, nicknameTextField, emailTextField])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        view.addSubview(saveButton)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            nameTextField.heightAnchor.constraint(equalToConstant: 45),
            nicknameTextField.heightAnchor.constraint(equalToConstant: 45),
            emailTextField.heightAnchor.constraint(equalToConstant: 45),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    private func createTextField(placeholder: String, text: String) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.text = text
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .none
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }
    @objc private func saveTapped() {
        guard let token = TokenManager.shared.getAccessToken() else { return }
        let updatedBody = UpdateProfileRequest(
            name: nameTextField.text ?? "",
            nickname: nicknameTextField.text ?? "",
            email: emailTextField.text ?? "",
            favoriteSports: favoriteSports
        )
        saveButton.isEnabled = false
        let networkService = ProfileNetworkService()
        networkService.updateProfile(userId: userId, accessToken: token, body: updatedBody) { [weak self] result in
            DispatchQueue.main.async {
                self?.saveButton.isEnabled = true
                switch result {
                case .success:
                    self?.onSaveSuccess?()
                    self?.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    print("Ошибка обновления профиля: \(error.localizedDescription)")
                }
            }
        }
    }
}
