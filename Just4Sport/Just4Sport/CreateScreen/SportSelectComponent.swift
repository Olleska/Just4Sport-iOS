import UIKit

final class SelfSizingCollectionView: UICollectionView {
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    override var intrinsicContentSize: CGSize {
        return contentSize
    }
}

class sportSelectComponent: UIView {
    private var sports: [String] = []
    var onValueSelected: (() -> Void)?
    var selectedValue: String? {
        guard let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first else { return nil }
        return sports[selectedIndexPath.item]
    }
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .SemiBold.body
        label.textColor = UIColor(named: "redColor")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var collectionView: SelfSizingCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 10
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let cv = SelfSizingCollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.allowsMultipleSelection = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupCollectionView()
    }
    required init?(coder: NSCoder) {
        fatalError("cat")
    }
    func configure(title: String, sports: [String]) {
        titleLabel.text = title
        self.sports = sports
        collectionView.reloadData()
    }
    func getSelectedSport() -> String? {
        guard let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first else { return nil }
        return sports[selectedIndexPath.item]
    }
    func resetSelection() {
        if let selectedIndexPaths = collectionView.indexPathsForSelectedItems {
            for indexPath in selectedIndexPaths {
                collectionView.deselectItem(at: indexPath, animated: false)
            }
        }
        collectionView.reloadData()
    }
    private func setupLayout() {
        addSubview(titleLabel)
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(SportSelectionViewCell.self, forCellWithReuseIdentifier: SportSelectionViewCell.identifier)
    }
}

extension sportSelectComponent: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sports.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SportSelectionViewCell.identifier, for: indexPath) as? SportSelectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: sports[indexPath.item])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onValueSelected?()
    }
}

final class SportSelectionViewCell: UICollectionViewCell {
    static let identifier = "SportSelectionViewCell"
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
        updateState()
    }
    required init?(coder: NSCoder) {
        fatalError("cat")
    }
    func configure(with sportName: String) {
        titleLabel.text = sportName
    }
    private func setupLayout() {
        layer.cornerRadius = 14
        clipsToBounds = true
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
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
