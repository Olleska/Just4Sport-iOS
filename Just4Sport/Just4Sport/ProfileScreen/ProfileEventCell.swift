import UIKit

final class PaddingLabelCell: UILabel {
    var topInset: CGFloat = 2
    var bottomInset: CGFloat = 2
    var leftInset: CGFloat = 8
    var rightInset: CGFloat = 8
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }
    override var bounds: CGRect {
        didSet {
            if numberOfLines == 0 && bounds.size.width != oldValue.size.width {
                invalidateIntrinsicContentSize()
            }
        }
    }
}

final class ProfileEventCell: UICollectionViewCell {
    static let identifier = "ProfileEventCell"
    private static let inputDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static let outputDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "grayColor")?.withAlphaComponent(0.2)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .Bold.body
        label.textColor = .black
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var sportLabel: PaddingLabelCell = {
        let label = PaddingLabelCell()
        label.font = .Regular.footnote1
        label.textColor = UIColor(named: "redColor")
        label.backgroundColor = UIColor(named: "redColor")?.withAlphaComponent(0.2)
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var typeLabel: PaddingLabelCell = {
        let label = PaddingLabelCell()
        label.font = .Regular.footnote1
        label.textColor = UIColor(named: "eventTypeColor")
        label.backgroundColor = UIColor(named: "eventTypeColor")?.withAlphaComponent(0.2)
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var skillLabel: PaddingLabelCell = {
        let label = PaddingLabelCell()
        label.font = .Regular.footnote1
        label.textColor = UIColor(named: "greenColor")
        label.backgroundColor = UIColor(named: "greenColor")?.withAlphaComponent(0.2)
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .Regular.footnote1
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    required init?(coder: NSCoder) {
        fatalError("cat")
    }
    private func setupLayout() {
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(sportLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(typeLabel)
        containerView.addSubview(skillLabel)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            typeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            typeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            sportLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 4),
            sportLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            skillLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 4),
            skillLabel.leadingAnchor.constraint(equalTo: sportLabel.trailingAnchor, constant: 4),
            dateLabel.topAnchor.constraint(equalTo: sportLabel.bottomAnchor, constant: 6),
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    func configure(with event: ProfileEvent) {
        titleLabel.text = event.name
        let sportType = SportType(rawValue: event.sport)?.visibleName ?? event.sport
        let skill = SkillLevel(rawValue: event.skillLevel)?.visibaleSkillLevel ?? ""
        let type = EventType(rawValue: event.eventType)?.visibaleType ?? ""
        sportLabel.text = "\(sportType)"
        skillLabel.text = "\(skill)"
        typeLabel.text = "\(type)"
        let shortDateRaw = String(event.dateStart.prefix(10))
        var displayDate = shortDateRaw
        if let dateObject = Self.inputDateFormatter.date(from: shortDateRaw) {
            displayDate = Self.outputDateFormatter.string(from: dateObject)
        }
        dateLabel.text = "\(displayDate) • \(event.cost) ₽"
    }
}
