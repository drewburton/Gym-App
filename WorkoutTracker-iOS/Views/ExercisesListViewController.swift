import UIKit
import SnapKit

class ExercisesListViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var exercisesByMuscleGroup: [MuscleGroup: [Exercise]] = [:]
    private var muscleGroups: [MuscleGroup] = []
    
    private var allExercises: [Exercise] = []
    private var filteredExercises: [Exercise] = []
    private var selectedMuscleGroups: Set<MuscleGroup> = []
    
    private let emptyStateView = EmptyStateView(
        imageName: "dumbbell",
        title: "No Exercises",
        message: "You haven't added any exercises yet.",
        buttonTitle: "Add Exercise"
    )
    
    private var isSearching: Bool {
        return searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupTableView()
        setupSearchController()
        setupNavigationBar()
        fetchData()
    }

    private func setupNavigationBar() {
        let filterButton = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease.circle"),
            style: .plain,
            target: self,
            action: #selector(filterButtonTapped)
        )
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
        
        navigationItem.rightBarButtonItems = [addButton, filterButton]
    }

    @objc private func addButtonTapped() {
        let editorVC = ExerciseEditorViewController()
        editorVC.delegate = self
        let nav = UINavigationController(rootViewController: editorVC)
        present(nav, animated: true)
    }

    @objc private func filterButtonTapped() {
        let alert = UIAlertController(title: "Filter by Muscle Group", message: nil, preferredStyle: .actionSheet)
        
        for group in MuscleGroup.allCases {
            let isSelected = selectedMuscleGroups.contains(group)
            let title = isSelected ? "✓ \(group.rawValue)" : group.rawValue
            alert.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                if isSelected {
                    self?.selectedMuscleGroups.remove(group)
                } else {
                    self?.selectedMuscleGroups.insert(group)
                }
                self?.updateSections()
                self?.tableView.reloadData()
            })
        }
        
        alert.addAction(UIAlertAction(title: "Clear All", style: .destructive) { [weak self] _ in
            self?.selectedMuscleGroups.removeAll()
            self?.updateSections()
            self?.tableView.reloadData()
        })
        
        alert.addAction(UIAlertAction(title: "Done", style: .cancel))
        
        present(alert, animated: true)
    }

    private func setupTableView() {
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        emptyStateView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        emptyStateView.actionHandler = { [weak self] in
            self?.addButtonTapped()
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ExerciseCell.self, forCellReuseIdentifier: ExerciseCell.reuseIdentifier)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search exercises"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    private func fetchData() {
        allExercises = WorkoutService.shared.getExercises()
        updateSections()
        tableView.reloadData()
        checkEmptyState()
    }

    private func checkEmptyState() {
        let isEmpty = isSearching ? filteredExercises.isEmpty : allExercises.isEmpty
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }

    @objc private func refreshData() {
        fetchData()
        tableView.refreshControl?.endRefreshing()
    }

    private func updateSections() {
        var source = isSearching ? filteredExercises : allExercises
        
        if !selectedMuscleGroups.isEmpty {
            source = source.filter { selectedMuscleGroups.contains($0.muscleGroup) }
        }
        
        exercisesByMuscleGroup = Dictionary(grouping: source) { $0.muscleGroup }
        muscleGroups = exercisesByMuscleGroup.keys.sorted { $0.rawValue < $1.rawValue }
    }
}

extension ExercisesListViewController: ExerciseEditorDelegate {
    func didSaveExercise() {
        fetchData()
    }
}

extension ExercisesListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return muscleGroups.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let muscleGroup = muscleGroups[section]
        return exercisesByMuscleGroup[muscleGroup]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ExerciseCell.reuseIdentifier, for: indexPath) as! ExerciseCell
        let muscleGroup = muscleGroups[indexPath.section]
        if let exercise = exercisesByMuscleGroup[muscleGroup]?[indexPath.row] {
            cell.configure(with: exercise)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return muscleGroups[section].rawValue
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let muscleGroup = muscleGroups[indexPath.section]
        if let exercise = exercisesByMuscleGroup[muscleGroup]?[indexPath.row] {
            let editorVC = ExerciseEditorViewController(exercise: exercise)
            editorVC.delegate = self
            let nav = UINavigationController(rootViewController: editorVC)
            present(nav, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let muscleGroup = muscleGroups[indexPath.section]
            guard let exercise = exercisesByMuscleGroup[muscleGroup]?[indexPath.row], let exerciseId = exercise.id else { return }
            
            let alert = UIAlertController(title: "Delete Exercise?", message: "This will permanently delete '\(exercise.name)' and all its history.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                if DatabaseService.shared.deleteExercise(exerciseId) {
                    self?.fetchData()
                }
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
        }
    }
}

extension ExercisesListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        if searchText.isEmpty {
            filteredExercises = []
        } else {
            filteredExercises = allExercises.filter { 
                $0.name.lowercased().contains(searchText.lowercased()) 
            }
        }
        updateSections()
        tableView.reloadData()
        checkEmptyState()
    }
}
