import UIKit

class GameRegisterViewController: UIViewController {
    
    private let eventId: String
    private let captainNickname: String
    private let networkService = EventNetworkService.shared
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Регистрация команды"
        label.font = .Bold.title3
        label.textColor = .black
        return label
    }()
    private let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .fill
        return stack
    }()
    private let nameTextField = createTextField(placeholder: "Название вашей команды")
    private let captainTextField = createTextField(placeholder: "Никнейм капитана")
    private let contactTextField = createTextField(placeholder: "Контактные данные")
    private let membersTextField = createTextField(placeholder: "Никнеймы участников (через запятую)")
    private lazy var submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отправить заявку", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .Bold.body
        button.backgroundColor = UIColor(named: "redColor") ?? .systemRed
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(sendApplicationButtonTapped), for: .touchUpInside)
        return button
    }()
    init(eventId: String, captainNickname: String) {
        self.eventId = eventId
        self.captainNickname = captainNickname
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("cat")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(containerStackView)
        view.addSubview(submitButton)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.addArrangedSubview(nameTextField)
        containerStackView.addArrangedSubview(captainTextField)
        containerStackView.addArrangedSubview(contactTextField)
        containerStackView.addArrangedSubview(membersTextField)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            containerStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            containerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            containerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            submitButton.topAnchor.constraint(equalTo: containerStackView.bottomAnchor, constant: 32),
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            submitButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    @objc private func sendApplicationButtonTapped() {
        let teamName = nameTextField.text ?? ""
        let captainNick = captainTextField.text ?? ""
        let contactInfo = contactTextField.text ?? ""
        let membersRawText = membersTextField.text ?? ""
        let membersArray = membersRawText
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !teamName.isEmpty, !captainNick.isEmpty, !contactInfo.isEmpty else {
            print("Заполните обязательные поля")
            return
        }
        let requestBody = TeamApplicationRequest(
            name: teamName,
            captainNickname: captainNick,
            membersNicknames: membersArray,
            contactInformation: contactInfo
        )
        networkService.sendTeamApplication(id: self.eventId, body: requestBody) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Заявка успешно отправлена!")
                    self.dismiss(animated: true, completion: nil)
                case .failure(let error):
                    print("\(error.localizedDescription)")
                }
            }
        }
    }
    private static func createTextField(placeholder: String) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.font = .Regular.body
        tf.borderStyle = .none
        tf.backgroundColor = .systemGray6
        tf.layer.cornerRadius = 12
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 44))
        tf.leftView = paddingView
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return tf
    }
}
