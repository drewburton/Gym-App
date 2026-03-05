import UIKit
import SnapKit

class ActiveWorkoutViewController: UIViewController {

    private var exercises: [Exercise]
    private let templateId: Int64?
    private let workoutType: WorkoutType
    private var workoutExercises: [WorkoutExercise] = []
    private var setsByExercise: [Int64: [WorkoutSet]] = [:] // Key: Exercise ID
    private var previousSetsByExercise: [Int64: [WorkoutSet]] = [:] // Key: Exercise ID
    private var currentExerciseIndex = 0
    private var isEditingExercises: Bool = false {
        didSet {
            updateEditingState()
        }
    }
    
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 18, weight: .bold)
        label.text = "00:00"
        return label
    }()

    private let progressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = Theme.Colors.secondaryLabel
        label.textAlignment = .center
        return label
    }()

    private lazy var finishButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Finish", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.backgroundColor = Theme.Colors.success
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        button.addTarget(self, action: #selector(finishTapped), for: .touchUpInside)
        return button
    }()

    private let exerciseTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    private let restTimerLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 24, weight: .bold)
        label.textColor = .systemOrange
        label.text = "Rest: 00:00"
        label.isHidden = true
        return label
    }()

    private let previousButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left.circle.fill"), for: .normal)
        button.tintColor = .systemBlue
        return button
    }()

    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.right.circle.fill"), for: .normal)
        button.tintColor = .systemBlue
        return button
    }()

    private var workoutTimer: Timer?
    private var startTime: Date?

    init(exercises: [Exercise], templateId: Int64? = nil, workoutType: WorkoutType = .custom) {
        self.exercises = exercises
        self.templateId = templateId
        self.workoutType = workoutType
        super.init(nibName: nil, bundle: nil)
        
        for (index, exercise) in exercises.enumerated() {
            setupInitialSets(for: exercise, at: index)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupInitialSets(for exercise: Exercise, at index: Int) {
        let exerciseId = exercise.id ?? Int64(index) // Fallback for dummy data
        let we = WorkoutExercise(workoutId: 0, exerciseId: exerciseId, sortOrder: index)
        workoutExercises.append(we)
        
        // Fetch previous sets
        let previous = WorkoutService.shared.getLastSets(forExerciseId: exerciseId)
        previousSetsByExercise[exerciseId] = previous
        
        // Start with sets from previous workout, or one empty set if none
        if !previous.isEmpty {
            setsByExercise[exerciseId] = previous.map { pSet in
                WorkoutSet(
                    workoutExerciseId: 0,
                    setNumber: pSet.setNumber,
                    weight: pSet.weight,
                    reps: pSet.reps
                )
            }
        } else {
            let initialSet = WorkoutSet(
                workoutExerciseId: 0,
                setNumber: 1,
                weight: 0,
                reps: 0
            )
            setsByExercise[exerciseId] = [initialSet]
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setupTableView()
        setupNavigationBar()
        setupTimerService()
        startTimer()
        
        updateExerciseUI()
    }

    private func setupUI() {
        view.addSubview(progressLabel)
        view.addSubview(exerciseTitleLabel)
        view.addSubview(restTimerLabel)
        view.addSubview(tableView)
        view.addSubview(previousButton)
        view.addSubview(nextButton)

        progressLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Theme.Spacing.small)
            make.centerX.equalToSuperview()
        }

        exerciseTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(progressLabel.snp.bottom).offset(Theme.Spacing.tiny)
            make.leading.trailing.equalToSuperview().inset(60)
        }

        restTimerLabel.snp.makeConstraints { make in
            make.top.equalTo(exerciseTitleLabel.snp.bottom).offset(Theme.Spacing.small)
            make.centerX.equalToSuperview()
        }

        previousButton.snp.makeConstraints { make in
            make.centerY.equalTo(exerciseTitleLabel)
            make.leading.equalToSuperview().offset(Theme.Padding.horizontal)
            make.size.equalTo(44)
        }

        nextButton.snp.makeConstraints { make in
            make.centerY.equalTo(exerciseTitleLabel)
            make.trailing.equalToSuperview().offset(-Theme.Padding.horizontal)
            make.size.equalTo(44)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(restTimerLabel.snp.bottom).offset(Theme.Spacing.small)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        previousButton.addTarget(self, action: #selector(previousExercise), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextExercise), for: .touchUpInside)
    }

    private func setupTimerService() {
        TimerService.shared.onTick = { [weak self] remaining in
            let minutes = remaining / 60
            let seconds = remaining % 60
            self?.restTimerLabel.text = String(format: "Rest: %02d:%02d", minutes, seconds)
            self?.restTimerLabel.isHidden = remaining <= 0
        }
        
        TimerService.shared.onFinish = { [weak self] in
            self?.restTimerLabel.isHidden = true
            HapticService.shared.notification(type: .warning)
        }
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(WorkoutSetCell.self, forCellReuseIdentifier: WorkoutSetCell.reuseIdentifier)
        
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 60))
        let addSetButton = UIButton(type: .system)
        addSetButton.setTitle("Add Set", for: .normal)
        addSetButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        addSetButton.addTarget(self, action: #selector(addSetTapped), for: .touchUpInside)
        footer.addSubview(addSetButton)
        addSetButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        tableView.tableFooterView = footer
    }

    private func setupNavigationBar() {
        // Left: Cancel
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        
        // Right: Finish and Timer (ungrouped)
        let finishItem = UIBarButtonItem(customView: finishButton)
        let timerItem = UIBarButtonItem(customView: timerLabel)
        
        if isEditingExercises {
            navigationItem.rightBarButtonItems = [finishItem]
        } else {
            // Arrays are ordered from right-to-left in the navigation bar
            navigationItem.rightBarButtonItems = [finishItem, timerItem]
        }
        
        // Middle: Add and Edit
        let middleStack = UIStackView()
        middleStack.axis = .horizontal
        middleStack.spacing = 16
        
        let addBtn = UIButton(type: .system)
        addBtn.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        addBtn.addTarget(self, action: #selector(addExerciseTapped), for: .touchUpInside)
        
        let editBtn = UIButton(type: .system)
        let editIcon = self.isEditingExercises ? "checkmark.circle" : "list.bullet"
        editBtn.setImage(UIImage(systemName: editIcon), for: .normal)
        editBtn.addTarget(self, action: #selector(toggleEditingExercises), for: .touchUpInside)
        
        middleStack.addArrangedSubview(addBtn)
        middleStack.addArrangedSubview(editBtn)
        
        navigationItem.titleView = middleStack
    }

    @objc private func toggleEditingExercises() {
        isEditingExercises.toggle()
    }

    private func updateEditingState() {
        tableView.isEditing = isEditingExercises
        
        let showSetUI = !isEditingExercises
        exerciseTitleLabel.isHidden = !showSetUI
        previousButton.isHidden = !showSetUI
        nextButton.isHidden = !showSetUI
        progressLabel.isHidden = !showSetUI
        
        if isEditingExercises {
            restTimerLabel.isHidden = true
            tableView.tableFooterView = nil
        } else {
            // Restore "Add Set" button
            setupTableView() // Re-setup to add the footer again
            
            if exercises.isEmpty {
                dismiss(animated: true)
                return
            }
            
            if currentExerciseIndex >= exercises.count {
                currentExerciseIndex = exercises.count - 1
            }
            updateExerciseUI()
        }
        
        setupNavigationBar()
        tableView.reloadData()
    }

    @objc private func addExerciseTapped() {
        let pickerVC = ExercisePickerViewController()
        pickerVC.delegate = self
        let nav = UINavigationController(rootViewController: pickerVC)
        present(nav, animated: true)
    }

    private func startTimer() {
        startTime = Date()
        workoutTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }

    private func updateTimer() {
        guard let startTime = startTime else { return }
        let elapsed = Int(Date().timeIntervalSince(startTime))
        let minutes = elapsed / 60
        let seconds = elapsed % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }

    private func updateExerciseUI() {
        let exercise = exercises[currentExerciseIndex]
        exerciseTitleLabel.text = exercise.name
        
        previousButton.isEnabled = currentExerciseIndex > 0
        previousButton.alpha = previousButton.isEnabled ? 1.0 : 0.3
        
        nextButton.isEnabled = currentExerciseIndex < exercises.count - 1
        nextButton.alpha = nextButton.isEnabled ? 1.0 : 0.3
        
        tableView.reloadData()
        progressLabel.text = "Exercise \(currentExerciseIndex + 1) of \(exercises.count)"
        title = "" // Clear title since we use titleView
    }

    @objc private func previousExercise() {
        if currentExerciseIndex > 0 {
            currentExerciseIndex -= 1
            updateExerciseUI()
        }
    }

    @objc private func nextExercise() {
        if currentExerciseIndex < exercises.count - 1 {
            currentExerciseIndex += 1
            updateExerciseUI()
        }
    }

    @objc private func addSetTapped() {
        let exercise = exercises[currentExerciseIndex]
        let exerciseId = exercise.id ?? Int64(currentExerciseIndex)
        var sets = setsByExercise[exerciseId] ?? []
        
        let lastSet = sets.last
        let newSetNumber = (lastSet?.setNumber ?? 0) + 1
        
        var weight: Double = lastSet?.weight ?? 0
        var reps: Int = lastSet?.reps ?? 0
        
        // If there's a previous workout's set for this new set number, use it
        if let previousSets = previousSetsByExercise[exerciseId], (newSetNumber - 1) < previousSets.count {
            let pSet = previousSets[newSetNumber - 1]
            weight = pSet.weight
            reps = pSet.reps
        }
        
        let newSet = WorkoutSet(
            workoutExerciseId: 0,
            setNumber: newSetNumber,
            weight: weight,
            reps: reps
        )
        
        sets.append(newSet)
        setsByExercise[exerciseId] = sets
        
        tableView.insertRows(at: [IndexPath(row: sets.count - 1, section: 0)], with: .automatic)
    }

    @objc private func finishTapped() {
        // Filter exercises to only those with at least one completed set
        let completedExercises = workoutExercises.filter { we in
            setsByExercise[we.exerciseId]?.contains(where: { $0.isCompleted }) ?? false
        }
        
        if completedExercises.isEmpty {
            let alert = UIAlertController(title: "Empty Workout", message: "You haven't completed any sets. Do you want to discard this workout?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Discard", style: .destructive) { [weak self] _ in
                self?.dismiss(animated: true)
            })
            alert.addAction(UIAlertAction(title: "Resume", style: .cancel))
            present(alert, animated: true)
            return
        }

        // Create the workout record
        let workout = Workout(
            templateId: templateId,
            workoutType: workoutType,
            startedAt: startTime ?? Date(),
            completedAt: Date()
        )
        
        guard let workoutId = DatabaseService.shared.createWorkout(workout) else {
            dismiss(animated: true)
            return
        }
        
        // Save exercises and completed sets
        for (index, we) in completedExercises.enumerated() {
            var workoutExercise = we
            workoutExercise.workoutId = workoutId
            workoutExercise.sortOrder = index
            guard let weId = DatabaseService.shared.createWorkoutExercise(workoutExercise) else { continue }
            
            if let sets = setsByExercise[we.exerciseId] {
                for var set in sets {
                    if set.isCompleted {
                        set.workoutExerciseId = weId
                        _ = DatabaseService.shared.createWorkoutSet(set)
                    }
                }
            }
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("workoutDidFinish"), object: nil)
        dismiss(animated: true)
    }

    @objc private func cancelTapped() {
        let alert = UIAlertController(title: "Cancel Workout?", message: "Your progress will be lost.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes, Cancel", style: .destructive) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        alert.addAction(UIAlertAction(title: "Resume", style: .cancel))
        present(alert, animated: true)
    }

    private func showPRCelebration() {
        let alert = UIAlertController(title: "New PR! 🏆", message: "Congratulations! You've set a new personal record.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Awesome!", style: .default))
        present(alert, animated: true)
    }
}

extension ActiveWorkoutViewController: ExercisePickerDelegate {
    func didSelectExercises(_ selectedExercises: [Exercise]) {
        for exercise in selectedExercises {
            // Check if exercise is already in the workout
            if !exercises.contains(where: { $0.id == exercise.id }) {
                exercises.append(exercise)
                setupInitialSets(for: exercise, at: exercises.count - 1)
            }
        }
        updateExerciseUI()
    }
}

extension ActiveWorkoutViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isEditingExercises {
            return exercises.count
        }
        
        guard currentExerciseIndex < exercises.count else { return 0 }
        let exercise = exercises[currentExerciseIndex]
        let exerciseId = exercise.id ?? Int64(currentExerciseIndex)
        return setsByExercise[exerciseId]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isEditingExercises {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExerciseEditCell") ?? UITableViewCell(style: .default, reuseIdentifier: "ExerciseEditCell")
            cell.textLabel?.text = exercises[indexPath.row].name
            cell.showsReorderControl = true
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: WorkoutSetCell.reuseIdentifier, for: indexPath) as! WorkoutSetCell
        
        guard currentExerciseIndex < exercises.count else { return cell }
        let exercise = exercises[currentExerciseIndex]
        let exerciseId = exercise.id ?? Int64(currentExerciseIndex)
        
        if let sets = setsByExercise[exerciseId], indexPath.row < sets.count {
            let set = sets[indexPath.row]
            
            var previousText = "-"
            if let previousSets = previousSetsByExercise[exerciseId], indexPath.row < previousSets.count {
                let pSet = previousSets[indexPath.row]
                previousText = "\(pSet.weight) x \(pSet.reps)"
            }
            
            cell.configure(setNumber: set.setNumber, previous: previousText)
            
            cell.weightTextField.text = set.weight > 0 ? "\(set.weight)" : ""
            cell.repsTextField.text = set.reps > 0 ? "\(set.reps)" : ""
            
            cell.completeButton.tintColor = set.isCompleted ? .systemGreen : .systemGray
            cell.completeButton.tag = indexPath.row
            cell.completeButton.addTarget(self, action: #selector(setCompleteTapped(_:)), for: .touchUpInside)
            
            // Handle text field changes
            cell.weightTextField.tag = indexPath.row
            cell.repsTextField.tag = indexPath.row
            cell.weightTextField.addTarget(self, action: #selector(weightChanged(_:)), for: .editingChanged)
            cell.repsTextField.addTarget(self, action: #selector(repsChanged(_:)), for: .editingChanged)
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return isEditingExercises
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedExercise = exercises.remove(at: sourceIndexPath.row)
        exercises.insert(movedExercise, at: destinationIndexPath.row)
        
        let movedWorkoutExercise = workoutExercises.remove(at: sourceIndexPath.row)
        workoutExercises.insert(movedWorkoutExercise, at: destinationIndexPath.row)
        
        // Update currentExerciseIndex to follow the exercise being moved if it was current
        if currentExerciseIndex == sourceIndexPath.row {
            currentExerciseIndex = destinationIndexPath.row
        } else if sourceIndexPath.row < currentExerciseIndex && destinationIndexPath.row >= currentExerciseIndex {
            currentExerciseIndex -= 1
        } else if sourceIndexPath.row > currentExerciseIndex && destinationIndexPath.row <= currentExerciseIndex {
            currentExerciseIndex += 1
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            exercises.remove(at: indexPath.row)
            workoutExercises.remove(at: indexPath.row)
            
            if exercises.isEmpty {
                toggleEditingExercises()
                dismiss(animated: true)
                return
            }
            
            if currentExerciseIndex >= exercises.count {
                currentExerciseIndex = exercises.count - 1
            } else if indexPath.row < currentExerciseIndex {
                currentExerciseIndex -= 1
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    @objc private func setCompleteTapped(_ sender: UIButton) {
        let rowIndex = sender.tag
        let exercise = exercises[currentExerciseIndex]
        let exerciseId = exercise.id ?? Int64(currentExerciseIndex)
        
        guard var sets = setsByExercise[exerciseId], rowIndex < sets.count else { return }
        
        // Input validation
        if !sets[rowIndex].isCompleted {
            if sets[rowIndex].weight <= 0 || sets[rowIndex].reps <= 0 {
                HapticService.shared.notification(type: .error)
                let alert = UIAlertController(title: "Invalid Input", message: "Please enter a valid weight and reps before completing the set.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
                return
            }
        }
        
        sets[rowIndex].isCompleted.toggle()
        if sets[rowIndex].isCompleted {
            sets[rowIndex].completedAt = Date()
            TimerService.shared.start(duration: 90) // Default 90s
            HapticService.shared.notification(type: .success)
            
            // Check for PR
            if DatabaseService.shared.checkAndSavePR(
                exerciseId: exerciseId,
                weight: sets[rowIndex].weight,
                reps: sets[rowIndex].reps
            ) {
                showPRCelebration()
            }
        } else {
            TimerService.shared.stop()
            restTimerLabel.isHidden = true
        }
        
        setsByExercise[exerciseId] = sets
        tableView.reloadRows(at: [IndexPath(row: rowIndex, section: 0)], with: .none)
    }

    @objc private func weightChanged(_ sender: UITextField) {
        let rowIndex = sender.tag
        let exercise = exercises[currentExerciseIndex]
        let exerciseId = exercise.id ?? Int64(currentExerciseIndex)
        
        guard var sets = setsByExercise[exerciseId], rowIndex < sets.count else { return }
        sets[rowIndex].weight = Double(sender.text ?? "") ?? 0
        setsByExercise[exerciseId] = sets
    }

    @objc private func repsChanged(_ sender: UITextField) {
        let rowIndex = sender.tag
        let exercise = exercises[currentExerciseIndex]
        let exerciseId = exercise.id ?? Int64(currentExerciseIndex)
        
        guard var sets = setsByExercise[exerciseId], rowIndex < sets.count else { return }
        sets[rowIndex].reps = Int(sender.text ?? "") ?? 0
        setsByExercise[exerciseId] = sets
    }
}

