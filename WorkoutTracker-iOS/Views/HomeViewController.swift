import UIKit
import SnapKit

class HomeViewController: UIViewController {

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "WorkoutTracker"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        label.text = formatter.string(from: Date())
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()

    private let startWorkoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Workout", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = Theme.Colors.primary
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = Theme.Radius.medium
        return button
    }()

    private let templatesTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Your Templates"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        return label
    }()

    private let templatesScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private let templatesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.distribution = .fill
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchTemplates()
    }

    private func fetchTemplates() {
        let templates = WorkoutService.shared.getTemplates()
        
        // Remove old views
        templatesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for template in templates {
            let card = TemplateCardView()
            let exercises = DatabaseService.shared.getTemplateExercises(forTemplateId: template.id ?? 0)
            card.configure(
                with: template.name, 
                exercises: "\(exercises.count) exercises", 
                duration: "45 min" // TODO: Estimated duration
            )
            card.onTap = { [weak self] in
                self?.startWorkout(with: template)
            }
            templatesStackView.addArrangedSubview(card)
            card.snp.makeConstraints { make in
                make.width.equalTo(160)
            }
        }
    }

    private func startWorkout(with template: WorkoutTemplate) {
        let templateExercises = DatabaseService.shared.getTemplateExercises(forTemplateId: template.id ?? 0)
        var exercises: [Exercise] = []
        for te in templateExercises {
            if let exercise = DatabaseService.shared.getExercise(byId: te.exerciseId) {
                exercises.append(exercise)
            }
        }
        
        let activeVC = ActiveWorkoutViewController(exercises: exercises, templateId: template.id, workoutType: .custom)
        let nav = UINavigationController(rootViewController: activeVC)
        nav.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        present(nav, animated: true)
    }

    private func setupUI() {
        view.addSubview(headerLabel)
        view.addSubview(dateLabel)
        view.addSubview(startWorkoutButton)
        view.addSubview(templatesTitleLabel)
        view.addSubview(templatesScrollView)
        templatesScrollView.addSubview(templatesStackView)

        headerLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Theme.Spacing.medium)
            make.leading.equalToSuperview().offset(Theme.Padding.horizontal)
        }

        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom).offset(Theme.Spacing.tiny)
            make.leading.equalTo(headerLabel)
        }

        startWorkoutButton.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(Theme.Spacing.large)
            make.leading.trailing.equalToSuperview().inset(Theme.Padding.horizontal)
            make.height.equalTo(56)
        }

        startWorkoutButton.addTarget(self, action: #selector(startWorkoutTapped), for: .touchUpInside)

        templatesTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(startWorkoutButton.snp.bottom).offset(Theme.Spacing.extraLarge)
            make.leading.equalToSuperview().offset(Theme.Padding.horizontal)
        }

        templatesScrollView.snp.makeConstraints { make in
            make.top.equalTo(templatesTitleLabel.snp.bottom).offset(Theme.Spacing.medium)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(180)
        }

        templatesStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: Theme.Padding.horizontal, bottom: 0, right: Theme.Padding.horizontal))
            make.height.equalToSuperview()
        }
    }

    @objc private func startWorkoutTapped() {
        let quickWorkoutVC = QuickWorkoutViewController()
        let nav = UINavigationController(rootViewController: quickWorkoutVC)
        nav.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        present(nav, animated: true)
    }
}
