import UIKit

final class SportCollectionViewCell: UICollectionViewCell {
    static let identifier = "SportCollectionViewCell"
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .Bold.body
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    override var isSelected: Bool {
        didSet {
            updateState()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    required init?(coder: NSCoder) {
        fatalError("cat")
    }
    func configure(with sportName: String) {
        titleLabel.text = sportName
        updateState()
    }
    private func setupLayout() {
        layer.cornerRadius = 16
        clipsToBounds = true
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
        ])
    }
    private func updateState() {
        if isSelected {
            backgroundColor = UIColor(named: "redColor")?.withAlphaComponent(0.2)
            titleLabel.textColor = UIColor(named: "redColor")
        } else {
            backgroundColor = UIColor(named: "grayColor")?.withAlphaComponent(0.2)
            titleLabel.textColor = UIColor(named: "redColor")
        }
    }
}
