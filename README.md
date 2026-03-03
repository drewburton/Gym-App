# 🏋️‍♂️ WorkoutTracker

A powerful, native iOS and watchOS application designed for seamless gym workout tracking, template management, and personal record monitoring. Built with performance and user experience in mind using a fully programmatic UI and local SQLite persistence.

![iOS 18.0+](https://img.shields.io/badge/iOS-18.0%2B-blue?style=flat-square&logo=apple)
![watchOS 11.0+](https://img.shields.io/badge/watchOS-11.0%2B-orange?style=flat-square&logo=apple)
![Swift 5.9](https://img.shields.io/badge/Swift-5.9-F05138?style=flat-square&logo=swift)
![Status](https://img.shields.io/badge/Status-Phase%205%20In%20Progress-green?style=flat-square)

---

## ✨ Core Features

### 🏠 Home Screen
- **Daily Summary:** Quick glance at your fitness progress and current date.
- **Quick Actions:** Start an ad-hoc workout or resume your last session instantly.
- **Template Cards:** Horizontal scroll of your favorite workout routines (Push, Pull, Legs, etc.) with muscle group indicators.

### 📚 Exercise Library
- **Comprehensive Database:** Over 100+ seed exercises across 12 muscle groups.
- **Advanced Filtering:** Search and filter by muscle group or equipment type (Barbell, Dumbbell, Machine, etc.).
- **Custom Editor:** Create your own exercises with specific target muscles and notes.

### 📋 Template Management
- **Reusable Routines:** Build and save workout templates for consistent training.
- **Drag-and-Drop:** Easily reorder exercises within a template.
- **Smart Defaults:** Set default reps and sets for each exercise in your plan.

### ⚡ Active Workout Tracking
- **Real-time Input:** Streamlined weight and rep entry optimized for gym use.
- **Progressive Overload:** Instant lookup of previous workout values (weight/reps) for every exercise.
- **Smart Rest Timer:** Automatic countdown between sets with background support and live notifications.

### 📈 History & Personal Records (PRs)
- **Workout Breakdown:** Detailed view of past sessions, including total volume and duration.
- **PR Detection:** Automatic identification of 1RM, 5RM, and 10RM records.
- **Volume Tracking:** Visualize your strength gains over time.

### 🛠 System Integration
- **Haptics:** Precise physical feedback for set completion and PR achievements.
- **Notifications:** Rich alerts for rest timers and workout summaries.
- **Siri & Voice:** Voice announcements for rest time remaining and exercise transitions.
- **Accessibility:** Full support for Dynamic Type, VoiceOver, and high-contrast modes.

---

## 🏗 Project Structure

The project is organized into modular components to support cross-platform functionality:

```text
├── WorkoutTracker-iOS/      # Main iPhone application (UIKit + SnapKit)
├── WorkoutTracker-Watch/    # Apple Watch companion app (WatchKit)
├── Shared/                  # Shared data models and business logic
├── docs/                    # Detailed implementation plans and design docs
└── project.yml              # XcodeGen configuration
```

---

## 💻 Tech Stack

- **Language:** Swift 5.9
- **UI Framework:** UIKit (100% Programmatic via **SnapKit**)
- **Persistence:** **SQLite.swift** (Local-first architecture)
- **Project Management:** **XcodeGen**
- **Connectivity:** WatchConnectivity for iPhone-Watch synchronization

---

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0 or later
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

### Build Instructions

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-repo/WorkoutTracker.git
   cd WorkoutTracker
   ```

2. **Generate the Xcode Project:**
   ```bash
   xcodegen generate
   ```

3. **Build the iOS App (Simulator):**
   ```bash
   xcodebuild -project WorkoutTracker.xcodeproj \
     -scheme WorkoutTracker-iOS \
     -configuration Debug \
     -destination 'platform=iOS Simulator,name=iPhone 16' \
     build
   ```

4. **Build the Watch App (Simulator):**
   ```bash
   xcodebuild -project WorkoutTracker.xcodeproj \
     -scheme WorkoutTracker-Watch \
     -configuration Debug \
     -destination 'platform=watchOS Simulator,name=Apple Watch SE (44mm)' \
     build
   ```

---

## 🗺 Roadmap

- [x] **Phase 1:** Project Foundations & Data Models
- [x] **Phase 2:** iPhone Core UI (Tabs, Home, Exercises, Templates)
- [x] **Phase 3:** Active Workout & Timer Service
- [x] **Phase 4:** History & PR Tracking
- [ ] **Phase 5:** Apple Watch Companion (**In Progress**)
- [x] **Phase 6:** UI Polish, Haptics, and Accessibility

---

## 📄 License
This project is licensed under the MIT License - see the LICENSE file for details.
