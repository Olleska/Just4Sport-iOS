import UIKit

class MainViewController: UIViewController {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "JUST 4SPORT"
        label.font = .Bold.title2
        label.textColor = UIColor(named: "redColor")
        return label
    }()
    private lazy var searchField: UITextField = {
        let text = UITextField()
        text.font = .Regular.body
        text.layer.cornerRadius = 8
        text.layer.borderWidth = 0
        return text
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        view.backgroundColor = .white
        setup()
    }
    private func setup() {
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 67),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
        ])
    }
}

