import UIKit
import SnapKit

class WorkoutSetCell: UITableViewCell {
    
    static let reuseIdentifier = "WorkoutSetCell"
    
    private let setNumberLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let previousLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    let weightTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "0"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .decimalPad
        tf.textAlignment = .center
        return tf
    }()
    
    let repsTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "0"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .numberPad
        tf.textAlignment = .center
        return tf
    }()
    
    let completeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        button.tintColor = .systemGray
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(setNumberLabel)
        contentView.addSubview(previousLabel)
        contentView.addSubview(weightTextField)
        contentView.addSubview(repsTextField)
        contentView.addSubview(completeButton)
        
        setNumberLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Theme.Spacing.small)
            make.centerY.equalToSuperview()
            make.width.equalTo(30)
        }
        
        previousLabel.snp.makeConstraints { make in
            make.leading.equalTo(setNumberLabel.snp.trailing).offset(Theme.Spacing.small)
            make.centerY.equalToSuperview()
            make.width.equalTo(80)
        }
        
        weightTextField.snp.makeConstraints { make in
            make.leading.equalTo(previousLabel.snp.trailing).offset(Theme.Spacing.small)
            make.centerY.equalToSuperview()
            make.width.equalTo(70)
        }
        
        repsTextField.snp.makeConstraints { make in
            make.leading.equalTo(weightTextField.snp.trailing).offset(Theme.Spacing.small)
            make.centerY.equalToSuperview()
            make.width.equalTo(60)
        }
        
        completeButton.snp.makeConstraints { make in
            make.leading.equalTo(repsTextField.snp.trailing).offset(Theme.Spacing.small)
            make.trailing.equalToSuperview().offset(-Theme.Spacing.small)
            make.centerY.equalToSuperview()
            make.width.equalTo(44)
        }
    }
    
    func configure(setNumber: Int, previous: String) {
        setNumberLabel.text = "\(setNumber)"
        setNumberLabel.accessibilityLabel = "Set number \(setNumber)"
        
        previousLabel.text = previous
        previousLabel.accessibilityLabel = "Previous performance \(previous)"
        
        weightTextField.accessibilityLabel = "Weight"
        weightTextField.accessibilityHint = "Enter weight in pounds"
        
        repsTextField.accessibilityLabel = "Reps"
        repsTextField.accessibilityHint = "Enter number of repetitions"
        
        completeButton.accessibilityLabel = "Complete set"
        completeButton.accessibilityHint = "Toggle set completion status"
    }
}
