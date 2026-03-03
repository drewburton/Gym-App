import UIKit
import SnapKit

class TemplatesListViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var templates: [WorkoutTemplate] = []
    private var exerciseCounts: [Int64: Int] = [:]
    
    private let emptyStateView = EmptyStateView(
        imageName: "doc.text",
        title: "No Templates",
        message: "Create workout templates to quickly start your favorite routines.",
        buttonTitle: "Create Template"
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupTableView()
        setupNavigationBar()
        fetchData()
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
        tableView.register(TemplateCell.self, forCellReuseIdentifier: TemplateCell.reuseIdentifier)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
    }

    private func fetchData() {
        templates = WorkoutService.shared.getTemplates()
        
        // Fetch exercise counts for each template
        for template in templates {
            if let id = template.id {
                let count = DatabaseService.shared.getTemplateExercises(forTemplateId: id).count
                exerciseCounts[id] = count
            }
        }
        
        tableView.reloadData()
        checkEmptyState()
    }

    private func checkEmptyState() {
        emptyStateView.isHidden = !templates.isEmpty
        tableView.isHidden = templates.isEmpty
    }

    @objc private func refreshData() {
        fetchData()
        tableView.refreshControl?.endRefreshing()
    }

    @objc private func addButtonTapped() {
        let editorVC = TemplateEditorViewController()
        editorVC.delegate = self
        let nav = UINavigationController(rootViewController: editorVC)
        present(nav, animated: true)
    }
}

extension TemplatesListViewController: TemplateEditorDelegate {
    func didSaveTemplate() {
        fetchData()
    }
}

extension TemplatesListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return templates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TemplateCell.reuseIdentifier, for: indexPath) as! TemplateCell
        let template = templates[indexPath.row]
        let count = exerciseCounts[template.id ?? 0] ?? 0
        cell.configure(with: template, exerciseCount: count)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let template = templates[indexPath.row]
        let editorVC = TemplateEditorViewController(template: template)
        editorVC.delegate = self
        let nav = UINavigationController(rootViewController: editorVC)
        present(nav, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let template = templates[indexPath.row]
            if let id = template.id {
                if DatabaseService.shared.deleteTemplate(id) {
                    templates.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
    }
}
