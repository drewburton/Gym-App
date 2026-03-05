import UIKit
import SnapKit

class QuickWorkoutViewController: UIViewController {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "New Workout"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        return label
    }()

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var selectedExercises: [Exercise] = []

    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Workout", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setupTableView()
        setupNavigationBar()
    }

    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(startButton)

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalToSuperview().offset(20)
        }

        startButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(56)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(startButton.snp.top).offset(-16)
        }
        
        startButton.addTarget(self, action: #selector(startWorkoutTapped), for: .touchUpInside)
        updateStartButtonState()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "QuickExerciseCell")
        tableView.isEditing = true
    }

    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        
        let addAction = UIAction(title: "Add Exercise", image: UIImage(systemName: "plus")) { [weak self] _ in
            self?.addExerciseTapped()
        }
        let menu = UIMenu(children: [addAction])
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus.circle"), menu: menu)
    }

    private func updateStartButtonState() {
        startButton.isEnabled = !selectedExercises.isEmpty
        startButton.alpha = selectedExercises.isEmpty ? 0.5 : 1.0
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func addExerciseTapped() {
        let pickerVC = ExercisePickerViewController()
        pickerVC.delegate = self
        let nav = UINavigationController(rootViewController: pickerVC)
        present(nav, animated: true)
    }

    @objc private func startWorkoutTapped() {
        // Task 3.1.2: Transition to ActiveWorkoutViewController
        let activeVC = ActiveWorkoutViewController(exercises: selectedExercises, templateId: nil, workoutType: .custom)
        navigationController?.pushViewController(activeVC, animated: true)
    }
}

extension QuickWorkoutViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedExercises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuickExerciseCell", for: indexPath)
        cell.textLabel?.text = selectedExercises[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let moved = selectedExercises.remove(at: sourceIndexPath.row)
        selectedExercises.insert(moved, at: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            selectedExercises.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            updateStartButtonState()
        }
    }
}

extension QuickWorkoutViewController: ExercisePickerDelegate {
    func didSelectExercises(_ exercises: [Exercise]) {
        for exercise in exercises {
            if !selectedExercises.contains(where: { $0.id == exercise.id }) {
                selectedExercises.append(exercise)
            }
        }
        tableView.reloadData()
        updateStartButtonState()
    }
}
