import UIKit
import SnapKit

class HistoryListViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var allWorkouts: [Workout] = []
    private var filteredWorkouts: [Workout] = []
    private var workoutsByMonth: [[Workout]] = []
    private var sectionTitles: [String] = []
    private var templateNames: [Int64: String] = [:]
    private let searchController = UISearchController(searchResultsController: nil)
    
    private let emptyStateView = EmptyStateView(
        imageName: "clock",
        title: "No History",
        message: "Your completed workouts will appear here."
    )
    
    private var isSearching: Bool {
        return searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupTableView()
        setupSearchController()
        fetchData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: NSNotification.Name("workoutDidFinish"), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "HistoryCell")
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search history"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    private func fetchData() {
        allWorkouts = WorkoutService.shared.fetchWorkouts()
        
        // Fetch template names
        for workout in allWorkouts {
            if let tId = workout.templateId {
                if let template = DatabaseService.shared.getTemplate(byId: tId) {
                    templateNames[tId] = template.name
                }
            }
        }
        
        updateSections()
        tableView.reloadData()
        checkEmptyState()
    }

    private func checkEmptyState() {
        let isEmpty = isSearching ? filteredWorkouts.isEmpty : allWorkouts.isEmpty
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }

    private func updateSections() {
        let source = isSearching ? filteredWorkouts : allWorkouts
        
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: source) { workout -> Date in
            let components = calendar.dateComponents([.year, .month], from: workout.startedAt)
            return calendar.date(from: components)!
        }
        
        let sortedKeys = grouped.keys.sorted(by: >)
        sectionTitles = sortedKeys.map { date -> String in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: date)
        }
        
        workoutsByMonth = sortedKeys.map { grouped[$0]!.sorted(by: { $0.startedAt > $1.startedAt }) }
    }

    @objc private func refreshData() {
        fetchData()
        tableView.refreshControl?.endRefreshing()
    }
}

extension HistoryListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workoutsByMonth[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "HistoryCell")
        let workout = workoutsByMonth[indexPath.section][indexPath.row]
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        let templateName = templateNames[workout.templateId ?? 0] ?? "Custom Workout"
        cell.textLabel?.text = templateName
        
        var details = formatter.string(from: workout.startedAt)
        if let completedAt = workout.completedAt {
            let duration = Int(completedAt.timeIntervalSince(workout.startedAt) / 60)
            details += " • \(duration) min"
        }
        
        cell.detailTextLabel?.text = details
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let workout = workoutsByMonth[indexPath.section][indexPath.row]
        let detailVC = WorkoutDetailViewController(workout: workout)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let workout = workoutsByMonth[indexPath.section][indexPath.row]
            if let workoutId = workout.id {
                if DatabaseService.shared.deleteWorkout(workoutId) {
                    // Refresh data
                    fetchData()
                }
            }
        }
    }
}

extension HistoryListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text?.lowercased() ?? ""
        if searchText.isEmpty {
            filteredWorkouts = []
        } else {
            filteredWorkouts = allWorkouts.filter { workout in
                let templateName = templateNames[workout.templateId ?? 0] ?? "Custom Workout"
                return templateName.lowercased().contains(searchText)
            }
        }
        updateSections()
        tableView.reloadData()
        checkEmptyState()
    }
}
