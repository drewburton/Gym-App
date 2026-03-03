# WorkoutTracker Implementation Plan

## 1. Project Overview

WorkoutTracker is a native iOS and watchOS application designed to help users track their gym workouts, manage exercise templates, and monitor personal records over time. The app uses a local SQLite database for data persistence and features Apple Watch connectivity for seamless workout tracking across devices.

### Current Status

**Phase 1 is COMPLETE.** The following foundational components have been implemented:

- XcodeGen project.yml with iOS 25.0+ and watchOS 11.0+ targets
- WorkoutTracker.xcodeproj generated
- All data models (Exercise, WorkoutTemplate, Workout, WorkoutExercise, WorkoutSet, PersonalRecord, ActiveWorkoutState, MuscleGroup, EquipmentType, WorkoutType)
- DatabaseService with SQLite.swift for local persistence
- 112 seed exercises across 12 muscle groups
- 3 default workout templates: Push Day, Pull Day, Leg Day
- Dependencies configured: SQLite.swift, SnapKit
- Basic AppDelegate and SceneDelegate setup

---

## 2. Phase 2: iPhone Core UI

This phase establishes the main user interface structure for the iPhone application, implementing the core navigation and view controllers needed for workout management.

### 2.1 Tab Bar Controller Setup

**Task 2.1.1: Create MainTabBarController**

- Create MainTabBarController extending UITabBarController
- Configure 4 tabs: Home, Exercises, Templates, History
- Set up tab bar icons using SF Symbols
- Apply consistent tab bar appearance styling
- Handle tab selection and delegate methods

**Task 2.1.2: Configure Navigation Controllers**

- Embed each tab in a UINavigationController
- Configure navigation bar appearance (large titles where appropriate)
- Set up navigation bar buttons and styling
- Implement push and pop transition behaviors

### 2.2 Home Screen

**Task 2.2.1: Create HomeViewController**

- Design home screen layout with SnapKit constraints
- Implement header with app title and current date
- Add "Start Workout" prominent quick action button
- Create horizontal scroll view for template cards
- Display recent workout summary section
- Implement weekly workout streak indicator

**Task 2.2.2: Create TemplateCardView**

- Design reusable template card component
- Display template name, exercise count, estimated duration
- Show muscle groups targeted with visual indicators
- Add tap gesture for template selection
- Implement card shadow and corner radius styling

### 2.3 Exercises List

**Task 2.3.1: Create ExercisesListViewController**

- Set up table view with exercise data source
- Implement section headers by muscle group
- Create custom exercise cell with name, muscle group, equipment type
- Add pull-to-refresh functionality
- Implement section collapse/expand behavior

**Task 2.3.2: Implement Search and Filter**

- Add UISearchController with search bar
- Implement real-time search filtering by exercise name
- Add filter button for muscle group selection
- Create filter popover with multi-select muscle groups
- Implement equipment type filter options
- Combine search and filter logic with AND/OR toggle

**Task 2.3.3: Create ExerciseEditorViewController**

- Implement form for creating new exercises
- Add text fields for exercise name
- Create muscle group picker (single and secondary selection)
- Add equipment type picker
- Implement notes/text view for exercise instructions
- Add save and cancel navigation buttons
- Implement edit mode for existing exercises

### 2.4 Templates Management

**Task 2.4.1: Create TemplatesListViewController**

- Set up table view displaying all workout templates
- Create template cell showing name, exercise count, last used date
- Add swipe actions for delete and duplicate
- Implement reorder mode for template list
- Add floating action button for new template

**Task 2.4.2: Create TemplateEditorViewController**

- Implement template name text field
- Add exercise selection list (reorderable)
- Create "Add Exercise" action that presents exercise picker
- Implement exercise reordering with drag-and-drop
- Add set/rep defaults per exercise
- Implement template save and cancel functionality

**Task 2.4.3: Create ExercisePickerViewController**

- Display searchable list of all exercises
- Implement multi-select capability
- Show selected exercises with checkmarks
- Add "Add New Exercise" option that presents ExerciseEditorViewController
- Implement confirmation button for selection

### 2.5 Navigation Structure

**Task 2.5.1: Implement Navigation Coordinators**

- Create AppCoordinator managing main navigation flow
- Implement TabBarCoordinator for each tab
- Create NavigationCoordinator protocol for child coordinators
- Handle deep linking from notifications or shortcuts

**Task 2.5.2: Configure App Shortcuts**

- Add UIApplicationShortcutItems to Info.plist
- Implement Quick Actions: Start Workout, Last Workout
- Handle shortcut item selection in AppDelegate
- Navigate to appropriate screen based on shortcut

---

## 3. Phase 3: Active Workout + Timer

This phase implements the core workout tracking functionality, including exercise execution, rest timer with notifications, and background support.

### 3.1 Workout Initialization

**Task 3.1.1: Create QuickWorkoutViewController**

- Implement exercise selection interface for ad-hoc workouts
- Add exercise search and filter functionality
- Create selected exercises list (reorderable)
- Add exercise removal with swipe or tap
- Implement "Start Workout" button
- Store selected exercises in ActiveWorkoutState

**Task 3.1.2: Create ActiveWorkoutViewController**

- Implement main workout execution screen
- Display current exercise with set/rep/weight inputs
- Add previous values display from last workout
- Create set completion tracking (checkmarks)
- Implement exercise navigation (previous/next)
- Add rest timer auto-start on set completion
- Display workout elapsed time
- Implement workout pause/resume functionality

**Task 3.1.3: Implement Workout Set Entry**

- Create custom input view for weight (numeric keyboard)
- Create custom input view for reps (numeric keyboard)
- Add increment/decrement buttons (+2.5, +5, +10 weight)
- Implement "Same as Previous Set" quick action
- Add RPE (Rate of Perceived Exertion) selector (optional)
- Store each set entry in WorkoutSet model

### 3.2 Rest Timer

**Task 3.2.1: Create TimerService**

- Implement singleton timer management service
- Create countdown timer with configurable duration
- Add timer state management (running, paused, stopped)
- Implement timer delegate/callback for state changes
- Add background timer continuation support
- Store last used rest time in UserDefaults

**Task 3.2.2: Create NotificationService**

- Request notification permissions on first timer use
- Implement local notification scheduling
- Add notification categories with actions (Skip, +30s)
- Implement notification content with workout context
- Handle notification tap to return to app
- Cancel pending notifications when workout ends

**Task 3.2.3: Implement Siri Voice Announcements**

- Integrate Speech framework for Siri notifications
- Announce rest time remaining at intervals (30s, 10s, done)
- Announce exercise transitions
- Add "Siri Voice" toggle in settings
- Configure announcement frequency preferences

**Task 3.2.4: Configure Background Modes**

- Enable background modes in Info.plist (audio, processing)
- Implement background task for timer continuation
- Handle app backgrounding during active workout
- Restore workout state when returning to foreground
- Show timer notification in notification center

### 3.3 Previous Values Logic

**Task 3.3.1: Implement Last Workout History Lookup**

- Query previous workout containing same exercise
- Retrieve last performed sets, reps, and weights
- Display previous values above input fields
- Implement "Copy Last Workout" feature for each exercise
- Handle case when no previous workout exists

**Task 3.3.2: Implement Auto-Populate Logic**

- Pre-fill weight/reps fields with last used values
- Add "Start with last values" toggle in settings
- Implement progressive overload suggestions (+2.5lbs/1rep)
- Show personal record indicators when exceeding previous max

---

## 4. Phase 4: History + PR Tracking

This phase implements workout history viewing, detailed workout analysis, and personal record detection and display.

### 4.1 History List

**Task 4.1.1: Create HistoryListViewController**

- Implement table view with workout history entries
- Create workout summary cell: date, duration, exercise count, template name
- Add section headers by month/year
- Implement pull-to-refresh for data reload
- Add swipe-to-delete functionality
- Implement search by workout name or date

**Task 4.1.2: Create WorkoutDetailViewController**

- Display complete workout breakdown
- Show all exercises with their sets
- Display weight, reps, RPE for each set
- Show workout duration and total volume
- Add "Copy Workout" to create new template
- Implement share functionality (text summary)

### 4.2 Personal Records

**Task 4.2.1: Implement PR Detection Logic**

- Compare current set weight to historical maximum
- Track PR by exercise, weight rep combinations
- Store PRs in PersonalRecord model
- Implement 1RM (One Rep Max) estimation calculation
- Detect PR for different rep ranges (1RM, 5RM, 10RM)

**Task 4.2.2: Create PR Display UI**

- Add crown/PR icon next to PR sets in ActiveWorkoutViewController
- Display PR badges in WorkoutDetailViewController
- Show PR history per exercise in exercise detail
- Implement "All PRs" section in profile/settings
- Add PR streak tracking (new PRs in consecutive workouts)

**Task 4.2.3: Implement PR Celebration**

- Show congratulatory alert when PR is achieved
- Add PR animation/effect in UI
- Log PR achievements in history
- Implement PR notifications (optional)

### 4.3 Workout Management

**Task 4.3.1: Implement Delete Workout**

- Add delete confirmation alert
- Soft delete vs hard delete option in settings
- Update history list after deletion
- Handle deletion of associated PRs appropriately
- Implement undo functionality (immediately after delete)

---

## 5. Phase 5: Apple Watch Companion

This phase implements the Apple Watch application with WatchConnectivity for seamless iPhone-Watch synchronization.

### 5.1 Watch Connectivity

**Task 5.1.1: Create WatchConnectivityService**

- Implement WCSession delegate handling
- Create singleton service for cross-device communication
- Implement message sending/receiving between devices
- Handle activation and state changes
- Implement reachable and activation states
- Add background transfer support for workout data

**Task 5.1.2: Implement Data Sync**

- Sync workout templates from iPhone to Watch
- Sync exercise database to Watch
- Sync active workout state between devices
- Handle sync conflicts and last-write-wins
- Implement incremental sync for efficiency

**Task 5.1.3: Implement Auto-Start Sync**

- Detect workout start on iPhone
- Automatically send start signal to Watch
- Sync timer state between devices in real-time
- Sync exercise changes during workout
- Handle disconnection during active workout

### 5.2 Watch UI

**Task 5.2.1: Create Watch Workout Interface**

- Implement main watch workout screen
- Display current exercise name (scroll if long)
- Show current set number and target reps
- Add weight input using digital crown
- Add rep counter with tap gestures
- Display rest timer with countdown
- Implement workout completion button

**Task 5.2.2: Implement Digital Crown Integration**

- Use WKInterfaceController crown sequences
- Map crown rotation to weight increment/decrement
- Map crown rotation to rep count adjustment
- Configure sensitivity and snap points
- Haptic feedback on value changes

**Task 5.2.3: Create Watch Exercise List**

- Display available exercises from sync
- Implement scrolling exercise selection
- Add exercises to current workout
- Show workout progress indicator

### 5.3 Watch Notifications and Siri

**Task 5.3.1: Implement Watch Notifications**

- Mirror iPhone rest timer notifications to Watch
- Add notification actions (Skip, Add Time)
- Handle notification responses
- Implement haptic alerts for transitions

**Task 5.3.2: Implement Siri on Watch**

- Add Siri intents for starting workouts
- Implement "Start [Template] Workout" voice command
- Add "Start Quick Workout" intent
- Handle workout completion via Siri

---

## 6. Phase 6: Polish

This phase focuses on user experience refinements, error handling, and final UI improvements.

### 6.1 Empty States

**Task 6.1.1: Create Empty State Views**

- Design empty state for Exercises (no exercises yet)
- Design empty state for Templates (no templates yet)
- Design empty state for History (no workouts yet)
- Design empty state for Active Workout (no exercises added)
- Implement consistent empty state appearance
- Add CTA buttons to guide user actions

### 6.2 Error Handling

**Task 6.2.1: Implement Database Error Handling**

- Handle database connection failures
- Implement retry logic for failed queries
- Show user-friendly error messages
- Log errors for debugging (optional crash reporting)

**Task 6.2.2: Implement Network/Connectivity Errors**

- Handle WatchConnectivity disconnection gracefully
- Show reconnection status indicators
- Implement offline mode for Watch (cached data)
- Handle sync failures with retry options

**Task 6.2.3: Implement Input Validation**

- Validate weight and rep inputs (positive numbers)
- Validate exercise names (non-empty)
- Validate template names (non-empty)
- Show inline validation errors
- Prevent saving invalid data

### 6.3 Haptic Feedback

**Task 6.3.1: Create HapticService**

- Implement UIImpactFeedbackGenerator for actions
- Implement UINotificationFeedbackGenerator for success/errors
- Implement UISelectionFeedbackGenerator for selections
- Create haptic patterns for: set completion, PR achieved, timer complete
- Add haptic toggle in settings

**Task 6.3.2: Apply Haptics Throughout App**

- Add haptics to button taps
- Add haptics to set completion
- Add haptics to timer events
- Add haptics to PR achievement
- Add haptics to exercise navigation

### 6.4 UI Refinements

**Task 6.4.1: Implement Theme Support**

- Define app color palette
- Implement dark mode support
- Create consistent typography styles
- Apply corner radius standards
- Implement spacing system (margins, padding)

**Task 6.4.2: Animations and Transitions**

- Add view controller transitions
- Implement cell animations (insertion, deletion)
- Add loading state animations
- Implement timer pulse animation
- Add PR celebration animations

**Task 6.4.3: Accessibility**

- Implement VoiceOver labels
- Add dynamic type support
- Ensure sufficient color contrast
- Implement reduce motion support
- Test with accessibility inspector

---

## 7. Key Services to Implement

### 7.1 TimerService

- Manage rest timer countdown
- Support configurable durations (30s, 60s, 90s, 120s, custom)
- Timer state management (start, pause, resume, stop)
- Delegate callbacks for UI updates
- Background timer continuation
- Store preferences in UserDefaults

### 7.2 NotificationService

- Request and manage notification permissions
- Schedule local notifications for timer
- Handle notification actions (skip, add time)
- Integrate with Siri speech synthesis
- Manage notification categories

### 7.3 WatchConnectivityService

- Manage WCSession lifecycle
- Send/receive messages between iPhone and Watch
- Handle file transfers for bulk data
- Sync active workout state
- Handle activation and reachability states

### 7.4 HapticService

- Provide centralized haptic feedback
- Support different haptic types and intensities
- Enable/disable haptics based on settings
- Create custom haptic patterns

---

## 8. Build Instructions

### 8.1 Prerequisites

- Xcode: Version 15.0 or later
- XcodeGen: Installed via Homebrew (brew install xcodegen)
- Xcode License: Accept the license agreement

### 8.2 First-Time Setup

**Accept Xcode License:**

```bash
sudo xcodebuild -license
```

### 8.3 Generate Project

```bash
cd /Users/drewburton/dev/Gym-App
xcodegen generate
```

### 8.4 Build iOS App

```bash
xcodebuild -project WorkoutTracker.xcodeproj \
  -scheme WorkoutTracker-iOS \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build
```

### 8.5 Build Watch App

```bash
xcodebuild -project WorkoutTracker.xcodeproj \
  -scheme WorkoutTracker-Watch \
  -configuration Debug \
  -destination 'platform=watchOS Simulator,name=Apple Watch SE (44mm)' \
  build
```

---

## File Structure

```
WorkoutTracker-iOS/
├── App/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   └── Info.plist
├── Models/
│   ├── Exercise.swift
│   ├── PersonalRecord.swift
│   ├── WorkoutTemplate.swift
│   ├── TemplateExercise.swift
│   ├── WorkoutModel.swift
│   ├── WorkoutExercise.swift
│   ├── WorkoutSet.swift
│   ├── ActiveWorkoutState.swift
│   ├── MuscleGroup.swift
│   ├── EquipmentType.swift
│   └── WorkoutType.swift
├── Services/
│   ├── DatabaseService.swift
│   └── WorkoutService.swift
├── ViewModels/
│   └── WorkoutViewModel.swift
├── Views/
│   └── WorkoutViewController.swift
├── Utilities/
│   └── DateFormatterHelper.swift
└── Resources/
    └── Assets.xcassets/

WorkoutTracker-Watch/
├── WatchKit App/
│   ├── InterfaceController.swift
│   └── Assets.xcassets/
└── Info.plist

Shared/
└── Models/
    └── SharedWorkout.swift
```

---

*Document Version: 1.0*
*Last Updated: March 2026*
*Project: WorkoutTracker*
*Targets: iOS 25.0+, watchOS 11.0+*
