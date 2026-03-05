# Implementation Instructions: Reformat ActiveWorkoutViewController Header

1.  **Modify `WorkoutTracker-iOS/Views/ActiveWorkoutViewController.swift`:**
    
    *   **Add properties:**
        ```swift
        private let progressLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 14, weight: .medium)
            label.textColor = .secondaryLabel
            label.textAlignment = .center
            return label
        }()
        ```
    *   **Update `setupUI`:**
        *   Add `progressLabel` to the view.
        *   Update constraints:
            ```swift
            progressLabel.snp.makeConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide).offset(Theme.Spacing.small)
                make.leading.trailing.equalToSuperview()
            }
            
            exerciseTitleLabel.snp.makeConstraints { make in
                make.top.equalTo(progressLabel.snp.bottom).offset(Theme.Spacing.small)
                make.leading.trailing.equalToSuperview().inset(60)
            }
            ```
    *   **Update `setupNavigationBar`:**
        *   Set `navigationItem.leftBarButtonItem` to "Cancel" button.
        *   Set `navigationItem.rightBarButtonItem` to a "Finish" button (use `Theme.Colors.success` color if possible, or just standard blue). Let's use standard blue for consistency unless asked otherwise. Actually, the existing `finishButton` had `Theme.Colors.success`. Let's use a `UIBarButtonItem` with custom view for "Finish" or just a `UIBarButtonItem(title: "Finish", ...)`
        *   Create a `titleView` containing a `UIStackView` with "Add" and "Edit" buttons.
        *   Remove the `ellipsis.circle` menu.
        *   Ensure the `timerLabel` is still visible if possible. Maybe put it on the right alongside "Finish".
        *   Wait, the user said "Move 'Finish Workout' to the right." and "Place 'Add' and 'Edit' buttons in the middle."
        *   Let's use a horizontal stack for "Add" and "Edit" in the `titleView`.

    *   **Update `updateExerciseUI`:**
        *   Set `progressLabel.text = "Exercise \(currentExerciseIndex + 1) of \(exercises.count)"`.
        *   Stop setting `self.title`.

    *   **Handle `isEditingExercises` state:**
        *   Update `editButton` title/image when toggled.
        *   When editing, "Cancel" might change to "Done" (wait, "Edit" button toggles `isEditingExercises`, so maybe `editButton` changes to "Done").

2.  **Verify with `reviewer`.**
