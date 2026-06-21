import UIKit

final class PaddingLabel: UILabel {
    private let insets = UIEdgeInsets(top: 1, left: 7, bottom: 3, right: 7)
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right, height: size.height + insets.top + insets.bottom)
    }
}

final class EventCardComponent: UIView {
    var onDetailsTap: (() -> Void)?
    lazy var detailsButton: UIButton = {
        let button = UIButton()
        button.setTitle("Подробнее", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .Bold.footnote
        button.backgroundColor = UIColor(named: "redColor")
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 34).isActive = true
        button.addTarget(self, action: #selector(detailsButtonTapped), for: .touchUpInside)
        return button
    }()
    lazy var eventImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor(named: "grayColor")?.withAlphaComponent(0.2)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .Bold.title3
        label.textColor = .black
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .Regular.body
        label.textColor = UIColor(named: "redColor")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var eventTypeLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.font = .Regular.body
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textColor = UIColor(named: "eventTypeColor")
        label.backgroundColor = UIColor(named: "eventTypeColor")?.withAlphaComponent(0.2)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var skillLevelLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.font = .Regular.body
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textColor = UIColor(named: "greenColor")
        label.backgroundColor = UIColor(named: "greenColor")?.withAlphaComponent(0.2)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var sportLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.font = .Regular.body
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textColor = UIColor(named: "redColor")
        label.backgroundColor = UIColor(named: "redColor")?.withAlphaComponent(0.2)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var eventStatusLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.font = .Regular.body
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textColor = .white
        label.backgroundColor = UIColor(named: "yellowColor")?.withAlphaComponent(0.7)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var tagsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [eventTypeLabel, skillLevelLabel, sportLabel])
        stack.axis = .vertical
        stack.spacing = 3
        stack.alignment = .leading
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    lazy var infoStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, dateLabel, tagsStackView])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    lazy var mainStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [eventImageView, infoStackView])
        stack.axis = .horizontal
        stack.spacing = 13
        stack.alignment = .top
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    required init?(coder: NSCoder) {
        fatalError("cat")
    }
    func configure(title: String, start: String, end: String, type: String, level: String, sport: String, status: String, imageUrlString: String?) {
        titleLabel.text = title
        eventTypeLabel.text = type
        skillLevelLabel.text = level
        sportLabel.text = sport
        eventStatusLabel.text = status
        if end.isEmpty {
                dateLabel.text = start
        } else {
            dateLabel.text = "\(start) — \(end)"
        }
        eventImageView.image = nil
        if let urlStr = imageUrlString, !urlStr.isEmpty {
            eventImageView.backgroundColor = .clear
            eventImageView.loadImage(from: urlStr, placeholder: nil)
        } else {
            eventImageView.image = nil
            eventImageView.backgroundColor = UIColor(named: "grayColor")?.withAlphaComponent(0.2)
        }
    }
    private func setupLayout() {
        addSubview(mainStackView)
        addSubview(detailsButton)
        addSubview(eventStatusLabel)
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            eventImageView.widthAnchor.constraint(equalToConstant: 152),
            eventImageView.heightAnchor.constraint(equalToConstant: 152),
            eventStatusLabel.topAnchor.constraint(equalTo: eventImageView.topAnchor, constant: 0),
            eventStatusLabel.leadingAnchor.constraint(equalTo: eventImageView.leadingAnchor, constant: 0),
            detailsButton.topAnchor.constraint(equalTo: mainStackView.bottomAnchor, constant: 12),
            detailsButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            detailsButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            detailsButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        ])
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        eventTypeLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        skillLevelLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    @objc private func detailsButtonTapped() {
        onDetailsTap?()
    }
}
