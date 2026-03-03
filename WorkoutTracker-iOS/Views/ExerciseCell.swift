import UIKit
import SnapKit

class ExerciseCell: UITableViewCell {
    
    static let reuseIdentifier = "ExerciseCell"
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        return label
    }()
    
    private let muscleGroupLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let equipmentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(muscleGroupLabel)
        contentView.addSubview(equipmentLabel)
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Theme.Spacing.medium)
            make.leading.equalToSuperview().offset(Theme.Padding.horizontal)
            make.trailing.equalToSuperview().offset(-Theme.Padding.horizontal)
        }
        
        muscleGroupLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(Theme.Spacing.tiny)
            make.leading.equalTo(nameLabel)
            make.bottom.equalToSuperview().offset(-Theme.Spacing.medium)
        }
        
        equipmentLabel.snp.makeConstraints { make in
            make.centerY.equalTo(muscleGroupLabel)
            make.trailing.equalToSuperview().offset(-Theme.Padding.horizontal)
            make.leading.greaterThanOrEqualTo(muscleGroupLabel.snp.trailing).offset(Theme.Spacing.small)
        }
    }
    
    func configure(with exercise: Exercise) {
        nameLabel.text = exercise.name
        nameLabel.accessibilityLabel = "Exercise name: \(exercise.name)"
        
        muscleGroupLabel.text = exercise.muscleGroup.rawValue
        muscleGroupLabel.accessibilityLabel = "Muscle group: \(exercise.muscleGroup.rawValue)"
        
        equipmentLabel.text = exercise.equipmentType.rawValue
        equipmentLabel.accessibilityLabel = "Equipment: \(exercise.equipmentType.rawValue)"
    }
}
