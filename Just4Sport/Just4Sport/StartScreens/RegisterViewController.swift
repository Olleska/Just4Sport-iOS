import UIKit
import Foundation

class RegisterViewController: UIViewController {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Регистрация"
        label.textColor = UIColor(named: "redColor")
        label.font = .Bold.title1
        return label
    }()
    private lazy var signUpButton: CustomButton = {
        let button = CustomButton(style: .firstType)
        button.setText("Продолжить")
        button.isAccessibilityElement = true
        return button
    }()
    private lazy var signInButton: CustomButton = {
        let button = CustomButton(style: .secondType)
        button.setText("Уже есть аккаунт?")
        button.isAccessibilityElement = true
        return button
    }()
    private lazy var nameField: CustomComponent = {
        let component = CustomComponent()
        component.configure(title: "Имя", placeholder: "Ваше имя", isSecure: false)
        return component
    }()
    private lazy var loginField: CustomComponent = {
        let component = CustomComponent()
        component.configure(title: "Nickname", placeholder: "Ваш nickname", isSecure: false)
        return component
    }()
    private lazy var emailField: CustomComponent = {
        let component = CustomComponent()
        component.configure(title: "Email", placeholder: "Ваш email", isSecure: false)
        return component
    }()
    private lazy var passwordField: CustomComponent = {
        let component = CustomComponent()
        component.configure(title: "Пароль", placeholder: "Придумайте пароль", isSecure: true)
        return component
    }()
    private lazy var checkPasswordField: CustomComponent = {
        let component = CustomComponent()
        component.configure(title: "Повторите пароль", placeholder: "Повторите пароль", isSecure: true)
        return component
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        view.backgroundColor = .white
        setup()
        signUpButton.addTarget(self, action: #selector(tapSelection), for: .touchUpInside)
        signInButton.addTarget(self, action: #selector(tapLogin), for: .touchUpInside)
        nameField.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        loginField.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        emailField.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        passwordField.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        checkPasswordField.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        updateRegisterButtonState()
    }
    @objc private func textFieldDidChange() {
        updateRegisterButtonState()
    }
    private func setup() {
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameField)
        nameField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginField)
        loginField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emailField)
        emailField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(passwordField)
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(checkPasswordField)
        checkPasswordField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(signUpButton)
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(signInButton)
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 71),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            nameField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 36),
            nameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            nameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            loginField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 23),
            loginField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            loginField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            emailField.topAnchor.constraint(equalTo: loginField.bottomAnchor, constant: 23),
            emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 23),
            passwordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            passwordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            checkPasswordField.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 23),
            checkPasswordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            checkPasswordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            signInButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            signInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            signUpButton.bottomAnchor.constraint(equalTo: signInButton.topAnchor, constant: -16),
            signUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    @objc func tapSelection() {
        let userData = RegistrationRequest(
            name: nameField.textField.text ?? "",
            nickname: loginField.textField.text ?? "",
            email: emailField.textField.text ?? "",
            password: passwordField.textField.text ?? "",
            favoriteSports: []
        )
        let selectionVC = SportsSelectionViewController(temporarySavedData: userData)
        navigationController?.pushViewController(selectionVC, animated: false)
    }
    @objc func tapLogin() {
        let loginVC = LoginViewController()
        navigationController?.pushViewController(loginVC, animated: false)
    }
    private func updateRegisterButtonState() {
        let nameText = nameField.textField.text ?? ""
        let isNameValid = !nameText.isEmpty
        let loginText = loginField.textField.text ?? ""
        let isLoginValid = !loginText.isEmpty && loginText.matchesBackendRegex
        let emailText = emailField.textField.text ?? ""
        let isEmailValid = !emailText.isEmpty && emailText.isValidEmail
        let pass1 = passwordField.textField.text ?? ""
        let isPasswordValid = !pass1.isEmpty && pass1.count >= 8 && pass1.matchesBackendRegex
        let pass2 = checkPasswordField.textField.text ?? ""
        let isCheckPasswordValid = !pass2.isEmpty && (pass1 == pass2)
        let isEnabled = isNameValid && isLoginValid && isEmailValid && isPasswordValid && isCheckPasswordValid
        signUpButton.isUserInteractionEnabled = isEnabled
        if !isEnabled {
            signUpButton.backgroundColor = UIColor(named: "redColor")?.withAlphaComponent(0.5)
            signUpButton.label.textColor = .white.withAlphaComponent(0.5)
        } else {
            signUpButton.backgroundColor = UIColor(named: "redColor")
            signUpButton.label.textColor = .white
        }
    }
}

extension String {
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPred.evaluate(with: self)
    }
    
    var matchesBackendRegex: Bool {
        let regex = "^[a-zA-Z0-9_\\.-]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
}
