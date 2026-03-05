import UIKit
import SnapKit

protocol TemplateEditorDelegate: AnyObject {
    func didSaveTemplate()
}

class TemplateEditorViewController: UIViewController {

    weak var delegate: TemplateEditorDelegate?
    private var template: WorkoutTemplate?
    private var exercises: [Exercise] = []
    
    private let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Template Name"
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Delete Template", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        return button
    }()
    
    init(template: WorkoutTemplate? = nil) {
        self.template = template
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = template == nil ? "New Template" : "Edit Template"
        setupUI()
        setupTableView()
        setupNavigationBar()
        fetchExercises()
    }

    private func setupUI() {
        view.addSubview(nameTextField)
        view.addSubview(tableView)

        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }

        if template != nil {
            view.addSubview(deleteButton)
            deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
            deleteButton.snp.makeConstraints { make in
                make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
                make.leading.trailing.equalToSuperview().inset(20)
                make.height.equalTo(50)
            }
            
            tableView.snp.makeConstraints { make in
                make.top.equalTo(nameTextField.snp.bottom).offset(20)
                make.leading.trailing.equalToSuperview()
                make.bottom.equalTo(deleteButton.snp.top).offset(-10)
            }
        } else {
            tableView.snp.makeConstraints { make in
                make.top.equalTo(nameTextField.snp.bottom).offset(20)
                make.leading.trailing.bottom.equalToSuperview()
            }
        }
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TemplateExerciseCell")
        tableView.isEditing = true
    }

    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        
        let saveAction = UIAction(title: "Save", image: UIImage(systemName: "checkmark")) { [weak self] _ in
            self?.saveTapped()
        }
        let addAction = UIAction(title: "Add Exercise", image: UIImage(systemName: "plus")) { [weak self] _ in
            self?.addExerciseTapped()
        }
        let menu = UIMenu(children: [saveAction, addAction])
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), menu: menu)
    }

    private func fetchExercises() {
        guard let templateId = template?.id else { return }
        let templateExercises = DatabaseService.shared.getTemplateExercises(forTemplateId: templateId)
        for te in templateExercises {
            if let exercise = DatabaseService.shared.getExercise(byId: te.exerciseId) {
                exercises.append(exercise)
            }
        }
        nameTextField.text = template?.name
        tableView.reloadData()
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

    @objc private func deleteTapped() {
        let alert = UIAlertController(
            title: "Delete Template",
            message: "Are you sure you want to delete this template? This action cannot be undone.",
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.performDeletion()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad support
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = deleteButton
            popoverController.sourceRect = deleteButton.bounds
        }
        
        present(alert, animated: true)
    }

    private func performDeletion() {
        guard let id = template?.id else { return }
        if DatabaseService.shared.deleteTemplate(id) {
            delegate?.didSaveTemplate()
            dismiss(animated: true)
        }
    }

    @objc private func saveTapped() {
        guard let name = nameTextField.text, !name.isEmpty else {
            HapticService.shared.notification(type: .error)
            let alert = UIAlertController(title: "Invalid Name", message: "Please enter a template name.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        if var template = template {
            template.name = name
            _ = DatabaseService.shared.updateTemplate(template)
            saveExercises(to: template.id!)
        } else {
            let newTemplate = WorkoutTemplate(name: name)
            if let newId = DatabaseService.shared.createTemplate(newTemplate) {
                saveExercises(to: newId)
            }
        }
        
        delegate?.didSaveTemplate()
        dismiss(animated: true)
    }

    private func saveExercises(to templateId: Int64) {
        // Clear existing exercises and re-add them to maintain order
        let existing = DatabaseService.shared.getTemplateExercises(forTemplateId: templateId)
        for te in existing {
            if let id = te.id {
                _ = DatabaseService.shared.deleteTemplateExercise(id)
            }
        }
        
        for (index, exercise) in exercises.enumerated() {
            if let exerciseId = exercise.id {
                let te = TemplateExercise(templateId: templateId, exerciseId: exerciseId, sortOrder: index)
                _ = DatabaseService.shared.createTemplateExercise(te)
            }
        }
    }
}

extension TemplateEditorViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TemplateExerciseCell", for: indexPath)
        cell.textLabel?.text = exercises[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedExercise = exercises.remove(at: sourceIndexPath.row)
        exercises.insert(movedExercise, at: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            exercises.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension TemplateEditorViewController: ExercisePickerDelegate {
    func didSelectExercises(_ selected: [Exercise]) {
        for exercise in selected {
            if !exercises.contains(where: { $0.id == exercise.id }) {
                exercises.append(exercise)
            }
        }
        tableView.reloadData()
    }
}
