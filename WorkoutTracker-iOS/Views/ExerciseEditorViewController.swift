import UIKit
import SnapKit

protocol ExerciseEditorDelegate: AnyObject {
    func didSaveExercise()
}

class ExerciseEditorViewController: UIViewController {

    weak var delegate: ExerciseEditorDelegate?
    private var exercise: Exercise?
    
    private let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Exercise Name"
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    private let muscleGroupLabel: UILabel = {
        let label = UILabel()
        label.text = "Muscle Group"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let muscleGroupPicker = UIPickerView()
    
    private let equipmentLabel: UILabel = {
        let label = UILabel()
        label.text = "Equipment Type"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let equipmentPicker = UIPickerView()
    
    private let notesTextView: UITextView = {
        let tv = UITextView()
        tv.layer.borderColor = UIColor.systemGray4.cgColor
        tv.layer.borderWidth = 1
        tv.layer.cornerRadius = 8
        return tv
    }()

    init(exercise: Exercise? = nil) {
        self.exercise = exercise
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = exercise == nil ? "New Exercise" : "Edit Exercise"
        setupUI()
        setupPickers()
        configureWithExercise()
        setupNavigationBar()
    }

    private func setupUI() {
        view.addSubview(nameTextField)
        view.addSubview(muscleGroupLabel)
        view.addSubview(muscleGroupPicker)
        view.addSubview(equipmentLabel)
        view.addSubview(equipmentPicker)
        view.addSubview(notesTextView)

        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }

        muscleGroupLabel.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }

        muscleGroupPicker.snp.makeConstraints { make in
            make.top.equalTo(muscleGroupLabel.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(120)
        }

        equipmentLabel.snp.makeConstraints { make in
            make.top.equalTo(muscleGroupPicker.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
        }

        equipmentPicker.snp.makeConstraints { make in
            make.top.equalTo(equipmentLabel.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(120)
        }

        notesTextView.snp.makeConstraints { make in
            make.top.equalTo(equipmentPicker.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(100)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).offset(-20)
        }
    }

    private func setupPickers() {
        muscleGroupPicker.delegate = self
        muscleGroupPicker.dataSource = self
        equipmentPicker.delegate = self
        equipmentPicker.dataSource = self
    }

    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
    }

    private func configureWithExercise() {
        guard let exercise = exercise else { return }
        nameTextField.text = exercise.name
        notesTextView.text = exercise.notes
        
        if let muscleIndex = MuscleGroup.allCases.firstIndex(of: exercise.muscleGroup) {
            muscleGroupPicker.selectRow(muscleIndex, inComponent: 0, animated: false)
        }
        
        if let equipIndex = EquipmentType.allCases.firstIndex(of: exercise.equipmentType) {
            equipmentPicker.selectRow(equipIndex, inComponent: 0, animated: false)
        }
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func saveTapped() {
        guard let name = nameTextField.text, !name.isEmpty else {
            HapticService.shared.notification(type: .error)
            let alert = UIAlertController(title: "Invalid Name", message: "Please enter an exercise name.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let selectedMuscle = MuscleGroup.allCases[muscleGroupPicker.selectedRow(inComponent: 0)]
        let selectedEquip = EquipmentType.allCases[equipmentPicker.selectedRow(inComponent: 0)]
        
        if var exercise = exercise {
            exercise.name = name
            exercise.muscleGroup = selectedMuscle
            exercise.equipmentType = selectedEquip
            exercise.notes = notesTextView.text
            _ = DatabaseService.shared.updateExercise(exercise)
        } else {
            let newExercise = Exercise(
                name: name,
                muscleGroup: selectedMuscle,
                equipmentType: selectedEquip,
                notes: notesTextView.text
            )
            _ = DatabaseService.shared.createExercise(newExercise)
        }
        
        delegate?.didSaveExercise()
        dismiss(animated: true)
    }
}

extension ExerciseEditorViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == muscleGroupPicker {
            return MuscleGroup.allCases.count
        } else {
            return EquipmentType.allCases.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == muscleGroupPicker {
            return MuscleGroup.allCases[row].rawValue
        } else {
            return EquipmentType.allCases[row].rawValue
        }
    }
}
