import UIKit
import SnapKit

protocol ExercisePickerDelegate: AnyObject {
    func didSelectExercises(_ exercises: [Exercise])
}

class ExercisePickerViewController: UIViewController {

    weak var delegate: ExercisePickerDelegate?
    private var selectedExercises: [Exercise] = []
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var exercisesByMuscleGroup: [MuscleGroup: [Exercise]] = [:]
    private var muscleGroups: [MuscleGroup] = []
    
    private var allExercises: [Exercise] = []
    private var filteredExercises: [Exercise] = []
    
    private var isSearching: Bool {
        return searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Pick Exercises"
        setupTableView()
        setupSearchController()
        setupNavigationBar()
        fetchData()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ExerciseCell.self, forCellReuseIdentifier: ExerciseCell.reuseIdentifier)
        tableView.allowsMultipleSelection = true
    }

    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search exercises"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
    }

    private func fetchData() {
        allExercises = WorkoutService.shared.getExercises()
        updateSections()
        tableView.reloadData()
    }

    private func updateSections() {
        let source = isSearching ? filteredExercises : allExercises
        exercisesByMuscleGroup = Dictionary(grouping: source) { $0.muscleGroup }
        muscleGroups = exercisesByMuscleGroup.keys.sorted { $0.rawValue < $1.rawValue }
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func doneTapped() {
        delegate?.didSelectExercises(selectedExercises)
        dismiss(animated: true)
    }
}

extension ExercisePickerViewController: UITableViewDelegate, UITableViewDataSource {
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
            
            if selectedExercises.contains(where: { $0.id == exercise.id }) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let muscleGroup = muscleGroups[indexPath.section]
        if let exercise = exercisesByMuscleGroup[muscleGroup]?[indexPath.row] {
            if !selectedExercises.contains(where: { $0.id == exercise.id }) {
                selectedExercises.append(exercise)
            }
        }
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let muscleGroup = muscleGroups[indexPath.section]
        if let exercise = exercisesByMuscleGroup[muscleGroup]?[indexPath.row] {
            selectedExercises.removeAll(where: { $0.id == exercise.id })
        }
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return muscleGroups[section].rawValue
    }
}

extension ExercisePickerViewController: UISearchResultsUpdating {
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
    }
}
