import UIKit
import SnapKit

class WorkoutDetailViewController: UIViewController {

    private let workout: Workout
    private var workoutExercises: [WorkoutExercise] = []
    private var exerciseData: [Int64: (Exercise, [WorkoutSet])] = [:]
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    init(workout: Workout) {
        self.workout = workout
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Workout Detail"
        setupUI()
        setupTableView()
        setupNavigationBar()
        fetchData()
    }

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
    }

    @objc private func shareTapped() {
        var summary = "My Workout Summary\n"
        let templateName = DatabaseService.shared.getTemplate(byId: workout.templateId ?? 0)?.name ?? "Custom Workout"
        summary += "\(templateName) on \(workout.startedAt.formatted())\n\n"
        
        for we in workoutExercises {
            if let (exercise, sets) = exerciseData[we.id!] {
                summary += "\(exercise.name):\n"
                for set in sets {
                    summary += "- Set \(set.setNumber): \(set.weight) lbs x \(set.reps)\n"
                }
                summary += "\n"
            }
        }
        
        let activityVC = UIActivityViewController(activityItems: [summary], applicationActivities: nil)
        present(activityVC, animated: true)
    }

    private func setupUI() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DetailCell")
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 100))
        let titleLabel = UILabel()
        
        let templateName = DatabaseService.shared.getTemplate(byId: workout.templateId ?? 0)?.name ?? "Custom Workout"
        titleLabel.text = templateName
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        
        let dateLabel = UILabel()
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        dateLabel.text = formatter.string(from: workout.startedAt)
        dateLabel.font = .systemFont(ofSize: 16)
        dateLabel.textColor = .secondaryLabel
        
        header.addSubview(titleLabel)
        header.addSubview(dateLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(20)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(titleLabel)
        }
        
        tableView.tableHeaderView = header
    }

    private func fetchData() {
        guard let workoutId = workout.id else { return }
        workoutExercises = DatabaseService.shared.getWorkoutExercises(forWorkoutId: workoutId)
        
        for we in workoutExercises {
            if let exercise = DatabaseService.shared.getExercise(byId: we.exerciseId) {
                let sets = DatabaseService.shared.getWorkoutSets(forWorkoutExerciseId: we.id!)
                exerciseData[we.id!] = (exercise, sets)
            }
        }
        
        tableView.reloadData()
    }
}

extension WorkoutDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return workoutExercises.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let weId = workoutExercises[section].id!
        return exerciseData[weId]?.1.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "DetailCell")
        let weId = workoutExercises[indexPath.section].id!
        if let (exercise, sets) = exerciseData[weId] {
            let set = sets[indexPath.row]
            
            let isPR = DatabaseService.shared.getPersonalRecords(forExerciseId: exercise.id!).contains { pr in
                pr.weight == set.weight && pr.reps == set.reps && Calendar.current.isDate(pr.achievedAt, inSameDayAs: workout.startedAt)
            }
            
            let prText = isPR ? " 🏆" : ""
            cell.textLabel?.text = "Set \(set.setNumber)\(prText)"
            cell.detailTextLabel?.text = "\(set.weight) lbs x \(set.reps)"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let weId = workoutExercises[section].id!
        return exerciseData[weId]?.0.name
    }
}
