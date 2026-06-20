import UIKit

class AddCommentViewController: UIViewController {
    
    private let eventId: String
    var onCommentSubmitted: (() -> Void)?
    private let dimmingBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        return view
    }()
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новый комментарий"
        label.font = .Bold.title3
        label.textColor = .black
        return label
    }()
    private let commentTextView: UITextView = {
        let tv = UITextView()
        tv.font = .Regular.body
        tv.textColor = .black
        tv.backgroundColor = UIColor(named: "grayColor")?.withAlphaComponent(0.1) ?? .systemGray6
        tv.layer.cornerRadius = 12
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return tv
    }()
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.systemGray, for: .normal)
        button.titleLabel?.font = .Bold.body
        button.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        return button
    }()
    private lazy var submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отправить", for: .normal)
        let redColor = UIColor(named: "redColor") ?? .systemRed
        button.setTitleColor(redColor, for: .normal)
        button.titleLabel?.font = .Bold.body
        button.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        return button
    }()
    
    private let buttonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 16
        return stack
    }()
    
    init(eventId: String) {
        self.eventId = eventId
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("cat")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        commentTextView.becomeFirstResponder()
    }
    
    private let containerCenterYConstraint: NSLayoutConstraint? = nil
    
    private func setupLayout() {
        view.addSubview(dimmingBackgroundView)
        view.addSubview(containerView)
        
        dimmingBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(commentTextView)
        containerView.addSubview(buttonsStackView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        commentTextView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        buttonsStackView.addArrangedSubview(cancelButton)
        buttonsStackView.addArrangedSubview(submitButton)
        
        // Используем приоритеты, чтобы карточка идеально прыгала над клавиатурой
        let centerYConstraint = containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        centerYConstraint.priority = .defaultLow // Разрешаем сжиматься/сдвигаться вверх
        
        NSLayoutConstraint.activate([
            dimmingBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmingBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmingBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmingBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            centerYConstraint,
            // Магия: держит окно над клавиатурой на расстоянии 20pt
            containerView.bottomAnchor.constraint(lessThanOrEqualTo: view.keyboardLayoutGuide.topAnchor, constant: -20),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            commentTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            commentTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            commentTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            commentTextView.heightAnchor.constraint(equalToConstant: 140), // Огромное текстовое поле
            
            buttonsStackView.topAnchor.constraint(equalTo: commentTextView.bottomAnchor, constant: 20),
            buttonsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            buttonsStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func cancelTapped() {
        commentTextView.resignFirstResponder()
        dismiss(animated: true)
    }
    
    @objc private func submitTapped() {
        guard let text = commentTextView.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        submitButton.isEnabled = false
        cancelButton.isEnabled = false
        commentTextView.isEditable = false
        
        EventNetworkService.shared.postComment(eventId: eventId, content: text) { [weak self] result in
            guard let self = self else { return }
            self.submitButton.isEnabled = true
            self.cancelButton.isEnabled = true
            self.commentTextView.isEditable = true
            
            switch result {
            case .success:
                self.commentTextView.resignFirstResponder()
                self.dismiss(animated: true) {
                    // Передаем сигнал наверх, что нужно обновить список комментов
                    self.onCommentSubmitted?()
                }
            case .failure(let error):
                print("Не удалось отправить комментарий через модалку: \(error.localizedDescription)")
                // Закрываем окно, даже если ошибка, чтобы разблокировать интерфейс пользователю
                self.commentTextView.resignFirstResponder()
                self.dismiss(animated: true) {
                    self.onCommentSubmitted?()
                }
            }
        }
    }
}
