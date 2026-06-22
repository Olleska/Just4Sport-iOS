import UIKit

class SportTagCell: UICollectionViewCell {
    static let identifier = "SportTagCell"
    private let tagLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "redColor")
        label.font = .SemiBold.body
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor(named: "redColor")?.withAlphaComponent(0.2)
        contentView.layer.cornerRadius = 14
        contentView.addSubview(tagLabel)
        NSLayoutConstraint.activate([
            tagLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            tagLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            tagLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tagLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    required init?(coder: NSCoder) {
        fatalError("cat")
    }
    func configure(with sportName: String) {
        tagLabel.text = sportName
    }
}
