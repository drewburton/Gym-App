import UIKit
import SnapKit

class TemplateCell: UITableViewCell {
    
    static let reuseIdentifier = "TemplateCell"
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        return label
    }()
    
    private let exerciseCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let lastUsedLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .tertiaryLabel
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
        contentView.addSubview(exerciseCountLabel)
        contentView.addSubview(lastUsedLabel)
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Theme.Spacing.medium)
            make.leading.equalToSuperview().offset(Theme.Padding.horizontal)
            make.trailing.equalToSuperview().offset(-Theme.Padding.horizontal)
        }
        
        exerciseCountLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(Theme.Spacing.tiny)
            make.leading.equalTo(nameLabel)
            make.bottom.equalToSuperview().offset(-Theme.Spacing.medium)
        }
        
        lastUsedLabel.snp.makeConstraints { make in
            make.centerY.equalTo(exerciseCountLabel)
            make.trailing.equalToSuperview().offset(-Theme.Padding.horizontal)
        }
    }
    
    func configure(with template: WorkoutTemplate, exerciseCount: Int) {
        nameLabel.text = template.name
        exerciseCountLabel.text = "\(exerciseCount) exercises"
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        lastUsedLabel.text = "Updated: \(formatter.string(from: template.updatedAt))"
    }
}
