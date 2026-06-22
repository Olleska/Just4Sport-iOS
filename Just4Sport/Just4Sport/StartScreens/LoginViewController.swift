import UIKit

class LoginViewController: UIViewController {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Вход"
        label.textColor = UIColor(named: "redColor")
        label.font = .Bold.title1
        return label
    }()
    private lazy var signInButton: CustomButton = {
        let button = CustomButton(style: .firstType)
        button.setText("Войти")
        button.isAccessibilityElement = true
        return button
    }()
    private lazy var signUpButton: CustomButton = {
        let button = CustomButton(style: .secondType)
        button.setText("Нет аккаунта?")
        button.isAccessibilityElement = true
        return button
    }()
    private lazy var emailField: CustomComponent = {
        let component = CustomComponent()
        component.configure(title: "Почта", placeholder: "Ваша почта", isSecure: false)
        return component
    }()
    private lazy var passwordField: CustomComponent = {
        let component = CustomComponent()
        component.configure(title: "Пароль", placeholder: "Ваш пароль", isSecure: true)
        return component
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        view.backgroundColor = .white
        setup()
        signUpButton.addTarget(self, action: #selector(tapRegister), for: .touchUpInside)
        signInButton.addTarget(self, action: #selector(tapMain), for: .touchUpInside)
        emailField.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        passwordField.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        updateLoginButtonState()
    }
    @objc private func textFieldDidChange() {
        updateLoginButtonState()
    }
    private func setup() {
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emailField)
        emailField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(passwordField)
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(signInButton)
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(signUpButton)
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 71),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emailField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 36),
            emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 23),
            passwordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            passwordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            signUpButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            signUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            signInButton.bottomAnchor.constraint(equalTo: signUpButton.topAnchor, constant: -16),
            signInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    @objc func tapRegister() {
        navigationController?.popViewController(animated: false)
    }
    private func updateLoginButtonState() {
        let emailText = emailField.textField.text ?? ""
        let isEmailValid = !emailText.isEmpty
        let passwordText = passwordField.textField.text ?? ""
        let isPasswordValid = !passwordText.isEmpty
        let isEnabled = isEmailValid && isPasswordValid
        signInButton.isUserInteractionEnabled = isEnabled
        if !isEnabled {
            signInButton.backgroundColor = UIColor(named: "redColor")?.withAlphaComponent(0.5)
            signInButton.label.textColor = .white.withAlphaComponent(0.5)
        } else {
            signInButton.backgroundColor = UIColor(named: "redColor")
            signInButton.label.textColor = .white
        }
    }
    @objc private func tapMain() {
        let emailText = emailField.textField.text ?? ""
        let passwordText = passwordField.textField.text ?? ""
        guard !emailText.isEmpty, !passwordText.isEmpty else {
            print("Заполните все поля")
            return
        }
        let loginData = LoginRequest(email: emailText, password: passwordText)
        AuthNetworkService.shared.login(requestModel: loginData) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    TokenManager.shared.saveTokens(accessToken: response.accessToken, refreshToken: response.refreshToken)
                    let mainVC = MainTabBarController()
                    self?.navigationController?.pushViewController(mainVC, animated: false)
                case .failure(let error):
                    print("Ошибка входа: \(error.localizedDescription)")
                }
            }
        }
    }
}
