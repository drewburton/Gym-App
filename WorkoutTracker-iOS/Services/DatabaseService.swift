import Foundation
import SQLite

final class DatabaseService {
    static let shared = DatabaseService()
    
    private var db: Connection?
    
    // MARK: - Table Definitions
    private let exercises = Table("exercises")
    private let personalRecords = Table("personal_records")
    private let templates = Table("templates")
    private let templateExercises = Table("template_exercises")
    private let workouts = Table("workouts")
    private let workoutExercises = Table("workout_exercises")
    private let workoutSets = Table("workout_sets")
    private let activeWorkout = Table("active_workout")
    
    // MARK: - Column Definitions - Exercises
    private let id = Expression<Int64>("id")
    private let name = Expression<String>("name")
    private let muscleGroup = Expression<String>("muscle_group")
    private let equipmentType = Expression<String>("equipment_type")
    private let notes = Expression<String?>("notes")
    private let createdAt = Expression<Date>("created_at")
    
    // MARK: - Column Definitions - Personal Records
    private let exerciseId = Expression<Int64>("exercise_id")
    private let weight = Expression<Double>("weight")
    private let reps = Expression<Int>("reps")
    private let achievedAt = Expression<Date>("achieved_at")
    
    // MARK: - Column Definitions - Templates
    private let templateId = Expression<Int64>("template_id")
    private let updatedAt = Expression<Date>("updated_at")
    
    // MARK: - Column Definitions - Template Exercises
    private let defaultSets = Expression<Int>("default_sets")
    private let defaultWeight = Expression<Double>("default_weight")
    private let defaultReps = Expression<Int>("default_reps")
    private let defaultRestSeconds = Expression<Int>("default_rest_seconds")
    private let sortOrder = Expression<Int>("sort_order")
    
    // MARK: - Column Definitions - Workouts
    private let workoutType = Expression<String>("workout_type")
    private let startedAt = Expression<Date>("started_at")
    private let completedAt = Expression<Date?>("completed_at")
    
    // MARK: - Column Definitions - Workout Exercises
    private let workoutId = Expression<Int64>("workout_id")
    
    // MARK: - Column Definitions - Workout Sets
    private let workoutExerciseId = Expression<Int64>("workout_exercise_id")
    private let setNumber = Expression<Int>("set_number")
    private let isCompleted = Expression<Bool>("is_completed")
    private let completedAtSet = Expression<Date?>("completed_at")
    
    // MARK: - Column Definitions - Active Workout
    private let currentExerciseIndex = Expression<Int>("current_exercise_index")
    private let currentSetNumber = Expression<Int>("current_set_number")
    private let timerEndTime = Expression<Date?>("timer_end_time")
    private let isTimerRunning = Expression<Bool>("is_timer_running")
    private let lastSyncedAt = Expression<Date?>("last_synced_at")
    
    // MARK: - Initialization
    private init() {
        setupDatabase()
    }
    
    private func setupDatabase() {
        do {
            let path = getDatabasePath()
            db = try Connection(path)
            createTables()
        } catch {
            print("Database connection error: \(error)")
        }
    }
    
    private func getDatabasePath() -> String {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsPath.appendingPathComponent("workout_tracker.sqlite3").path
    }
    
    private func createTables() {
        guard let db = db else { return }
        
        do {
            // Exercises table
            try db.run(exercises.create(ifNotExists: true) { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(name)
                t.column(muscleGroup)
                t.column(equipmentType)
                t.column(notes)
                t.column(createdAt, defaultValue: Date())
            })
            
            // Personal Records table
            try db.run(personalRecords.create(ifNotExists: true) { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(exerciseId)
                t.column(weight)
                t.column(reps)
                t.column(achievedAt, defaultValue: Date())
                t.foreignKey(exerciseId, references: exercises, id, delete: .cascade)
            })
            
            // Templates table
            try db.run(templates.create(ifNotExists: true) { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(name)
                t.column(createdAt, defaultValue: Date())
                t.column(updatedAt, defaultValue: Date())
            })
            
            // Template Exercises table
            try db.run(templateExercises.create(ifNotExists: true) { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(templateId)
                t.column(exerciseId)
                t.column(defaultSets, defaultValue: 3)
                t.column(defaultWeight, defaultValue: 0)
                t.column(defaultReps, defaultValue: 10)
                t.column(defaultRestSeconds, defaultValue: 90)
                t.column(sortOrder, defaultValue: 0)
                t.foreignKey(templateId, references: templates, id, delete: .cascade)
                t.foreignKey(exerciseId, references: exercises, id, delete: .cascade)
            })
            
            // Workouts table
            try db.run(workouts.create(ifNotExists: true) { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(templateId)
                t.column(workoutType)
                t.column(startedAt)
                t.column(completedAt)
                t.column(notes)
                t.foreignKey(templateId, references: templates, id, delete: .setNull)
            })
            
            // Workout Exercises table
            try db.run(workoutExercises.create(ifNotExists: true) { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(workoutId)
                t.column(exerciseId)
                t.column(sortOrder, defaultValue: 0)
                t.foreignKey(workoutId, references: workouts, id, delete: .cascade)
                t.foreignKey(exerciseId, references: exercises, id, delete: .cascade)
            })
            
            // Workout Sets table
            try db.run(workoutSets.create(ifNotExists: true) { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(workoutExerciseId)
                t.column(setNumber)
                t.column(weight)
                t.column(reps)
                t.column(isCompleted, defaultValue: false)
                t.column(completedAtSet)
                t.foreignKey(workoutExerciseId, references: workoutExercises, id, delete: .cascade)
            })
            
            // Active Workout table
            try db.run(activeWorkout.create(ifNotExists: true) { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(workoutId)
                t.column(currentExerciseIndex, defaultValue: 0)
                t.column(currentSetNumber, defaultValue: 1)
                t.column(timerEndTime)
                t.column(isTimerRunning, defaultValue: false)
                t.column(lastSyncedAt)
            })
            
        } catch {
            print("Table creation error: \(error)")
        }
    }
    
    // MARK: - Seed Data
    func seedDatabaseIfNeeded() {
        guard let db = db else { return }
        
        do {
            let count = try db.scalar(exercises.count)
            if count == 0 {
                seedExercises()
                seedDefaultTemplates()
            }
        } catch {
            print("Seed check error: \(error)")
        }
    }
    
    private func seedExercises() {
        let exerciseData: [(String, MuscleGroup, EquipmentType)] = [
            // Chest (15)
            ("Barbell Bench Press", .chest, .barbell),
            ("Incline Barbell Bench Press", .chest, .barbell),
            ("Decline Barbell Bench Press", .chest, .barbell),
            ("Dumbbell Bench Press", .chest, .dumbbell),
            ("Incline Dumbbell Press", .chest, .dumbbell),
            ("Decline Dumbbell Press", .chest, .dumbbell),
            ("Dumbbell Fly", .chest, .dumbbell),
            ("Cable Fly", .chest, .cable),
            ("Push-ups", .chest, .bodyweight),
            ("Chest Press Machine", .chest, .machine),
            ("Pec Deck", .chest, .machine),
            ("Dip", .chest, .bodyweight),
            ("Landmine Press", .chest, .barbell),
            ("Cable Crossover", .chest, .cable),
            ("Svend Press", .chest, .dumbbell),
            
            // Back (15)
            ("Deadlift", .back, .barbell),
            ("Conventional Deadlift", .back, .barbell),
            ("Sumo Deadlift", .back, .barbell),
            ("Trap Bar Deadlift", .back, .barbell),
            ("Pull-ups", .back, .bodyweight),
            ("Chin-ups", .back, .bodyweight),
            ("Lat Pulldown", .back, .cable),
            ("Seated Cable Row", .back, .cable),
            ("Barbell Row", .back, .barbell),
            ("Dumbbell Row", .back, .dumbbell),
            ("T-Bar Row", .back, .barbell),
            ("Face Pull", .back, .cable),
            ("Rack Pull", .back, .barbell),
            ("Shrugs", .back, .barbell),
            ("Back Extension", .back, .bodyweight),
            
            // Shoulders (12)
            ("Overhead Press", .shoulders, .barbell),
            ("Seated Dumbbell Press", .shoulders, .dumbbell),
            ("Arnold Press", .shoulders, .dumbbell),
            ("Lateral Raise", .shoulders, .dumbbell),
            ("Front Raise", .shoulders, .dumbbell),
            ("Rear Delt Fly", .shoulders, .dumbbell),
            ("Upright Row", .shoulders, .barbell),
            ("Cable Lateral Raise", .shoulders, .cable),
            ("Machine Shoulder Press", .shoulders, .machine),
            ("Landmine Press", .shoulders, .barbell),
            ("Face Pull", .shoulders, .cable),
            ("Shoulder Pin Press", .shoulders, .barbell),
            
            // Biceps (8)
            ("Barbell Curl", .biceps, .barbell),
            ("Dumbbell Curl", .biceps, .dumbbell),
            ("Hammer Curl", .biceps, .dumbbell),
            ("Preacher Curl", .biceps, .barbell),
            ("Incline Dumbbell Curl", .biceps, .dumbbell),
            ("Cable Curl", .biceps, .cable),
            ("Concentration Curl", .biceps, .dumbbell),
            ("Spider Curl", .biceps, .dumbbell),
            
            // Triceps (8)
            ("Close Grip Bench Press", .triceps, .barbell),
            ("Tricep Pushdown", .triceps, .cable),
            ("Overhead Tricep Extension", .triceps, .dumbbell),
            ("Skull Crusher", .triceps, .barbell),
            ("Dip", .triceps, .bodyweight),
            ("Kickback", .triceps, .dumbbell),
            ("Tricep Press Machine", .triceps, .machine),
            ("Diamond Push-ups", .triceps, .bodyweight),
            
            // Forearms (5)
            ("Wrist Curl", .forearms, .barbell),
            ("Reverse Wrist Curl", .forearms, .barbell),
            ("Farmer's Walk", .forearms, .dumbbell),
            ("Plate Pinch", .forearms, .other),
            ("Gripper", .forearms, .other),
            
            // Quadriceps (12)
            ("Back Squat", .quadriceps, .barbell),
            ("Front Squat", .quadriceps, .barbell),
            ("Leg Press", .quadriceps, .machine),
            ("Hack Squat", .quadriceps, .machine),
            ("Bulgarian Split Squat", .quadriceps, .dumbbell),
            ("Lunges", .quadriceps, .dumbbell),
            ("Walking Lunges", .quadriceps, .dumbbell),
            ("Step-Up", .quadriceps, .dumbbell),
            ("Leg Extension", .quadriceps, .machine),
            ("Goblet Squat", .quadriceps, .dumbbell),
            ("Sumo Squat", .quadriceps, .barbell),
            ("Pause Squat", .quadriceps, .barbell),
            
            // Hamstrings (8)
            ("Romanian Deadlift", .hamstrings, .barbell),
            ("Stiff Leg Deadlift", .hamstrings, .barbell),
            ("Leg Curl", .hamstrings, .machine),
            ("Nordic Curl", .hamstrings, .bodyweight),
            ("Glute Ham Raise", .hamstrings, .machine),
            ("Good Morning", .hamstrings, .barbell),
            ("Cable Pull-Through", .hamstrings, .cable),
            ("Kettlebell Swing", .hamstrings, .kettlebell),
            
            // Glutes (6)
            ("Hip Thrust", .glutes, .barbell),
            ("Glute Bridge", .glutes, .bodyweight),
            ("Cable Kickback", .glutes, .cable),
            ("Step-Up", .glutes, .dumbbell),
            ("Sumo Deadlift", .glutes, .barbell),
            ("Frog Pump", .glutes, .bodyweight),
            
            // Calves (5)
            ("Standing Calf Raise", .calves, .machine),
            ("Seated Calf Raise", .calves, .machine),
            ("Donkey Calf Raise", .calves, .machine),
            ("Leg Press Calf Raise", .calves, .machine),
            ("Single Leg Calf Raise", .calves, .bodyweight),
            
            // Core (12)
            ("Plank", .core, .bodyweight),
            ("Side Plank", .core, .bodyweight),
            ("Crunch", .core, .bodyweight),
            ("Sit-up", .core, .bodyweight),
            ("Leg Raise", .core, .bodyweight),
            ("Hanging Leg Raise", .core, .bodyweight),
            ("Russian Twist", .core, .bodyweight),
            ("Ab Wheel Rollout", .core, .other),
            ("Cable Crunch", .core, .cable),
            ("Mountain Climber", .core, .bodyweight),
            ("Dead Bug", .core, .bodyweight),
            ("Bird Dog", .core, .bodyweight),
            
            // Full Body (6)
            ("Clean and Press", .fullBody, .barbell),
            ("Clean", .fullBody, .barbell),
            ("Snatch", .fullBody, .barbell),
            ("Thruster", .fullBody, .barbell),
            ("Turkish Get-Up", .fullBody, .kettlebell),
            ("Burpee", .fullBody, .bodyweight)
        ]
        
        for exercise in exerciseData {
            _ = createExercise(Exercise(
                name: exercise.0,
                muscleGroup: exercise.1,
                equipmentType: exercise.2
            ))
        }
    }
    
    private func seedDefaultTemplates() {
        // Get exercise IDs
        let allExercises = getAllExercises()
        
        func findExerciseId(_ exerciseName: String) -> Int64? {
            return allExercises.first { $0.name == exerciseName }?.id
        }
        
        // Push Day Template
        let pushDayExercises: [(String, Int, Double, Int)] = [
            ("Barbell Bench Press", 3, 135, 8),
            ("Incline Barbell Bench Press", 3, 95, 8),
            ("Overhead Press", 3, 65, 10),
            ("Lateral Raise", 3, 15, 12),
            ("Tricep Pushdown", 3, 40, 12)
        ]
        
        if let pushTemplateId = createTemplate(WorkoutTemplate(name: "Push Day")) {
            for (index, ex) in pushDayExercises.enumerated() {
                if let exerciseId = findExerciseId(ex.0) {
                    _ = createTemplateExercise(TemplateExercise(
                        templateId: pushTemplateId,
                        exerciseId: exerciseId,
                        defaultSets: ex.1,
                        defaultWeight: ex.2,
                        defaultReps: ex.3,
                        defaultRestSeconds: 90,
                        sortOrder: index
                    ))
                }
            }
        }
        
        // Pull Day Template
        let pullDayExercises: [(String, Int, Double, Int)] = [
            ("Deadlift", 3, 185, 5),
            ("Pull-ups", 3, 0, 8),
            ("Barbell Row", 3, 95, 10),
            ("Face Pull", 3, 25, 15),
            ("Barbell Curl", 3, 55, 12)
        ]
        
        if let pullTemplateId = createTemplate(WorkoutTemplate(name: "Pull Day")) {
            for (index, ex) in pullDayExercises.enumerated() {
                if let exerciseId = findExerciseId(ex.0) {
                    _ = createTemplateExercise(TemplateExercise(
                        templateId: pullTemplateId,
                        exerciseId: exerciseId,
                        defaultSets: ex.1,
                        defaultWeight: ex.2,
                        defaultReps: ex.3,
                        defaultRestSeconds: 90,
                        sortOrder: index
                    ))
                }
            }
        }
        
        // Leg Day Template
        let legDayExercises: [(String, Int, Double, Int)] = [
            ("Back Squat", 3, 135, 8),
            ("Romanian Deadlift", 3, 95, 10),
            ("Leg Press", 3, 180, 12),
            ("Leg Curl", 3, 60, 12),
            ("Standing Calf Raise", 3, 100, 15)
        ]
        
        if let legTemplateId = createTemplate(WorkoutTemplate(name: "Leg Day")) {
            for (index, ex) in legDayExercises.enumerated() {
                if let exerciseId = findExerciseId(ex.0) {
                    _ = createTemplateExercise(TemplateExercise(
                        templateId: legTemplateId,
                        exerciseId: exerciseId,
                        defaultSets: ex.1,
                        defaultWeight: ex.2,
                        defaultReps: ex.3,
                        defaultRestSeconds: 90,
                        sortOrder: index
                    ))
                }
            }
        }
    }
    
    // MARK: - Exercise CRUD
    func createExercise(_ exercise: Exercise) -> Int64? {
        guard let db = db else { return nil }
        
        do {
            let insert = exercises.insert(
                name <- exercise.name,
                muscleGroup <- exercise.muscleGroup.rawValue,
                equipmentType <- exercise.equipmentType.rawValue,
                notes <- exercise.notes,
                createdAt <- exercise.createdAt
            )
            let rowId = try db.run(insert)
            return rowId
        } catch {
            print("Insert exercise error: \(error)")
            return nil
        }
    }
    
    func getAllExercises() -> [Exercise] {
        guard let db = db else { return [] }
        
        var result: [Exercise] = []
        
        do {
            for row in try db.prepare(exercises.order(name.asc)) {
                let exercise = Exercise(
                    id: row[id],
                    name: row[name],
                    muscleGroup: MuscleGroup(rawValue: row[muscleGroup]) ?? .chest,
                    equipmentType: EquipmentType(rawValue: row[equipmentType]) ?? .barbell,
                    notes: row[notes],
                    createdAt: row[createdAt]
                )
                result.append(exercise)
            }
        } catch {
            print("Get exercises error: \(error)")
        }
        
        return result
    }
    
    func getExercise(byId exerciseId: Int64) -> Exercise? {
        guard let db = db else { return nil }
        
        do {
            let query = exercises.filter(id == exerciseId)
            if let row = try db.pluck(query) {
                return Exercise(
                    id: row[id],
                    name: row[name],
                    muscleGroup: MuscleGroup(rawValue: row[muscleGroup]) ?? .chest,
                    equipmentType: EquipmentType(rawValue: row[equipmentType]) ?? .barbell,
                    notes: row[notes],
                    createdAt: row[createdAt]
                )
            }
        } catch {
            print("Get exercise error: \(error)")
        }
        
        return nil
    }
    
    func getExercisesByMuscleGroup(_ group: MuscleGroup) -> [Exercise] {
        guard let db = db else { return [] }
        
        var result: [Exercise] = []
        
        do {
            let query = exercises.filter(muscleGroup == group.rawValue).order(name.asc)
            for row in try db.prepare(query) {
                let exercise = Exercise(
                    id: row[id],
                    name: row[name],
                    muscleGroup: MuscleGroup(rawValue: row[muscleGroup]) ?? .chest,
                    equipmentType: EquipmentType(rawValue: row[equipmentType]) ?? .barbell,
                    notes: row[notes],
                    createdAt: row[createdAt]
                )
                result.append(exercise)
            }
        } catch {
            print("Get exercises by muscle group error: \(error)")
        }
        
        return result
    }
    
    func updateExercise(_ exercise: Exercise) -> Bool {
        guard let db = db, let exerciseId = exercise.id else { return false }
        
        do {
            let exerciseRow = exercises.filter(id == exerciseId)
            try db.run(exerciseRow.update(
                name <- exercise.name,
                muscleGroup <- exercise.muscleGroup.rawValue,
                equipmentType <- exercise.equipmentType.rawValue,
                notes <- exercise.notes
            ))
            return true
        } catch {
            print("Update exercise error: \(error)")
            return false
        }
    }
    
    func deleteExercise(_ exerciseId: Int64) -> Bool {
        guard let db = db else { return false }
        
        do {
            let exerciseRow = exercises.filter(id == exerciseId)
            try db.run(exerciseRow.delete())
            return true
        } catch {
            print("Delete exercise error: \(error)")
            return false
        }
    }
    
    // MARK: - Personal Record CRUD
    func createPersonalRecord(_ record: PersonalRecord) -> Int64? {
        guard let db = db else { return nil }
        
        do {
            let insert = personalRecords.insert(
                exerciseId <- record.exerciseId,
                weight <- record.weight,
                reps <- record.reps,
                achievedAt <- record.achievedAt
            )
            return try db.run(insert)
        } catch {
            print("Insert personal record error: \(error)")
            return nil
        }
    }
    
    func getPersonalRecords(forExerciseId exId: Int64) -> [PersonalRecord] {
        guard let db = db else { return [] }
        
        var result: [PersonalRecord] = []
        
        do {
            let query = personalRecords.filter(exerciseId == exId).order(achievedAt.desc)
            for row in try db.prepare(query) {
                let record = PersonalRecord(
                    id: row[id],
                    exerciseId: row[exerciseId],
                    weight: row[weight],
                    reps: row[reps],
                    achievedAt: row[achievedAt]
                )
                result.append(record)
            }
        } catch {
            print("Get personal records error: \(error)")
        }
        
        return result
    }
    
    func getLatestPersonalRecord(forExerciseId exId: Int64) -> PersonalRecord? {
        guard let db = db else { return nil }
        
        do {
            let query = personalRecords
                .filter(exerciseId == exId)
                .order(weight.desc, reps.desc)
                .limit(1)
            if let row = try db.pluck(query) {
                return PersonalRecord(
                    id: row[id],
                    exerciseId: row[exerciseId],
                    weight: row[weight],
                    reps: row[reps],
                    achievedAt: row[achievedAt]
                )
            }
        } catch {
            print("Get latest personal record error: \(error)")
        }
        
        return nil
    }
    
    func deletePersonalRecord(_ recordId: Int64) -> Bool {
        guard let db = db else { return false }
        
        do {
            let recordRow = personalRecords.filter(id == recordId)
            try db.run(recordRow.delete())
            return true
        } catch {
            print("Delete personal record error: \(error)")
            return false
        }
    }
    
    // MARK: - Template CRUD
    func createTemplate(_ template: WorkoutTemplate) -> Int64? {
        guard let db = db else { return nil }
        
        do {
            let insert = templates.insert(
                name <- template.name,
                createdAt <- template.createdAt,
                updatedAt <- template.updatedAt
            )
            return try db.run(insert)
        } catch {
            print("Insert template error: \(error)")
            return nil
        }
    }
    
    func getAllTemplates() -> [WorkoutTemplate] {
        guard let db = db else { return [] }
        
        var result: [WorkoutTemplate] = []
        
        do {
            for row in try db.prepare(templates.order(name.asc)) {
                let template = WorkoutTemplate(
                    id: row[id],
                    name: row[name],
                    createdAt: row[createdAt],
                    updatedAt: row[updatedAt]
                )
                result.append(template)
            }
        } catch {
            print("Get templates error: \(error)")
        }
        
        return result
    }
    
    func getTemplate(byId templateId: Int64) -> WorkoutTemplate? {
        guard let db = db else { return nil }
        
        do {
            let query = templates.filter(id == templateId)
            if let row = try db.pluck(query) {
                return WorkoutTemplate(
                    id: row[id],
                    name: row[name],
                    createdAt: row[createdAt],
                    updatedAt: row[updatedAt]
                )
            }
        } catch {
            print("Get template error: \(error)")
        }
        
        return nil
    }
    
    func updateTemplate(_ template: WorkoutTemplate) -> Bool {
        guard let db = db, let templateId = template.id else { return false }
        
        do {
            let templateRow = templates.filter(id == templateId)
            try db.run(templateRow.update(
                name <- template.name,
                updatedAt <- Date()
            ))
            return true
        } catch {
            print("Update template error: \(error)")
            return false
        }
    }
    
    func deleteTemplate(_ templateId: Int64) -> Bool {
        guard let db = db else { return false }
        
        do {
            let templateRow = templates.filter(id == templateId)
            try db.run(templateRow.delete())
            return true
        } catch {
            print("Delete template error: \(error)")
            return false
        }
    }
    
    // MARK: - Template Exercise CRUD
    func createTemplateExercise(_ templateExercise: TemplateExercise) -> Int64? {
        guard let db = db else { return nil }
        
        do {
            let insert = templateExercises.insert(
                templateId <- templateExercise.templateId,
                exerciseId <- templateExercise.exerciseId,
                defaultSets <- templateExercise.defaultSets,
                defaultWeight <- templateExercise.defaultWeight,
                defaultReps <- templateExercise.defaultReps,
                defaultRestSeconds <- templateExercise.defaultRestSeconds,
                sortOrder <- templateExercise.sortOrder
            )
            return try db.run(insert)
        } catch {
            print("Insert template exercise error: \(error)")
            return nil
        }
    }
    
    func getTemplateExercises(forTemplateId tmplId: Int64) -> [TemplateExercise] {
        guard let db = db else { return [] }
        
        var result: [TemplateExercise] = []
        
        do {
            let query = templateExercises.filter(templateId == tmplId).order(sortOrder.asc)
            for row in try db.prepare(query) {
                let templateExercise = TemplateExercise(
                    id: row[id],
                    templateId: row[templateId],
                    exerciseId: row[exerciseId],
                    defaultSets: row[defaultSets],
                    defaultWeight: row[defaultWeight],
                    defaultReps: row[defaultReps],
                    defaultRestSeconds: row[defaultRestSeconds],
                    sortOrder: row[sortOrder]
                )
                result.append(templateExercise)
            }
        } catch {
            print("Get template exercises error: \(error)")
        }
        
        return result
    }
    
    func updateTemplateExercise(_ templateExercise: TemplateExercise) -> Bool {
        guard let db = db, let templateExerciseId = templateExercise.id else { return false }
        
        do {
            let row = templateExercises.filter(id == templateExerciseId)
            try db.run(row.update(
                defaultSets <- templateExercise.defaultSets,
                defaultWeight <- templateExercise.defaultWeight,
                defaultReps <- templateExercise.defaultReps,
                defaultRestSeconds <- templateExercise.defaultRestSeconds,
                sortOrder <- templateExercise.sortOrder
            ))
            return true
        } catch {
            print("Update template exercise error: \(error)")
            return false
        }
    }
    
    func deleteTemplateExercise(_ templateExerciseId: Int64) -> Bool {
        guard let db = db else { return false }
        
        do {
            let row = templateExercises.filter(id == templateExerciseId)
            try db.run(row.delete())
            return true
        } catch {
            print("Delete template exercise error: \(error)")
            return false
        }
    }
    
    // MARK: - Workout CRUD
    func createWorkout(_ workout: Workout) -> Int64? {
        guard let db = db else { return nil }
        
        var setters: [Setter] = [
            workoutType <- workout.workoutType.rawValue,
            startedAt <- workout.startedAt,
            completedAt <- workout.completedAt,
            notes <- workout.notes
        ]
        
        if let tId = workout.templateId {
            setters.append(templateId <- tId)
        }
        
        do {
            let insert = workouts.insert(setters)
            return try db.run(insert)
        } catch {
            print("Insert workout error: \(error)")
            return nil
        }
    }
    
    func getAllWorkouts() -> [Workout] {
        guard let db = db else { return [] }
        
        var result: [Workout] = []
        
        do {
            for row in try db.prepare(workouts.order(startedAt.desc)) {
                let workout = Workout(
                    id: row[id],
                    templateId: row[templateId],
                    workoutType: WorkoutType(rawValue: row[workoutType]) ?? .custom,
                    startedAt: row[startedAt],
                    completedAt: row[completedAt],
                    notes: row[notes]
                )
                result.append(workout)
            }
        } catch {
            print("Get workouts error: \(error)")
        }
        
        return result
    }
    
    func getWorkout(byId workoutId: Int64) -> Workout? {
        guard let db = db else { return nil }
        
        do {
            let query = workouts.filter(id == workoutId)
            if let row = try db.pluck(query) {
                return Workout(
                    id: row[id],
                    templateId: row[templateId],
                    workoutType: WorkoutType(rawValue: row[workoutType]) ?? .custom,
                    startedAt: row[startedAt],
                    completedAt: row[completedAt],
                    notes: row[notes]
                )
            }
        } catch {
            print("Get workout error: \(error)")
        }
        
        return nil
    }
    
    func getActiveWorkout() -> Workout? {
        guard let db = db else { return nil }
        
        do {
            let query = workouts.filter(completedAt == nil).order(startedAt.desc).limit(1)
            if let row = try db.pluck(query) {
                return Workout(
                    id: row[id],
                    templateId: row[templateId],
                    workoutType: WorkoutType(rawValue: row[workoutType]) ?? .custom,
                    startedAt: row[startedAt],
                    completedAt: row[completedAt],
                    notes: row[notes]
                )
            }
        } catch {
            print("Get active workout error: \(error)")
        }
        
        return nil
    }
    
    func updateWorkout(_ workout: Workout) -> Bool {
        guard let db = db, let workoutId = workout.id else { return false }
        
        do {
            let workoutRow = workouts.filter(id == workoutId)
            if let tId = workout.templateId {
                try db.run(workoutRow.update(
                    self.templateId <- tId,
                    workoutType <- workout.workoutType.rawValue,
                    completedAt <- workout.completedAt,
                    notes <- workout.notes
                ))
            } else {
                try db.run(workoutRow.update(
                    workoutType <- workout.workoutType.rawValue,
                    completedAt <- workout.completedAt,
                    notes <- workout.notes
                ))
            }
            return true
        } catch {
            print("Update workout error: \(error)")
            return false
        }
    }
    
    func completeWorkout(_ workoutId: Int64) -> Bool {
        guard let db = db else { return false }
        
        do {
            let workoutRow = workouts.filter(id == workoutId)
            try db.run(workoutRow.update(completedAt <- Date()))
            return true
        } catch {
            print("Complete workout error: \(error)")
            return false
        }
    }
    
    func deleteWorkout(_ workoutId: Int64) -> Bool {
        guard let db = db else { return false }
        
        do {
            let workoutRow = workouts.filter(id == workoutId)
            try db.run(workoutRow.delete())
            return true
        } catch {
            print("Delete workout error: \(error)")
            return false
        }
    }
    
    // MARK: - Workout Exercise CRUD
    func createWorkoutExercise(_ workoutExercise: WorkoutExercise) -> Int64? {
        guard let db = db else { return nil }
        
        do {
            let insert = workoutExercises.insert(
                workoutId <- workoutExercise.workoutId,
                exerciseId <- workoutExercise.exerciseId,
                sortOrder <- workoutExercise.sortOrder
            )
            return try db.run(insert)
        } catch {
            print("Insert workout exercise error: \(error)")
            return nil
        }
    }
    
    func getWorkoutExercises(forWorkoutId wrkId: Int64) -> [WorkoutExercise] {
        guard let db = db else { return [] }
        
        var result: [WorkoutExercise] = []
        
        do {
            let query = workoutExercises.filter(workoutId == wrkId).order(sortOrder.asc)
            for row in try db.prepare(query) {
                let workoutExercise = WorkoutExercise(
                    id: row[id],
                    workoutId: row[workoutId],
                    exerciseId: row[exerciseId],
                    sortOrder: row[sortOrder]
                )
                result.append(workoutExercise)
            }
        } catch {
            print("Get workout exercises error: \(error)")
        }
        
        return result
    }
    
    func deleteWorkoutExercise(_ workoutExerciseId: Int64) -> Bool {
        guard let db = db else { return false }
        
        do {
            let row = workoutExercises.filter(id == workoutExerciseId)
            try db.run(row.delete())
            return true
        } catch {
            print("Delete workout exercise error: \(error)")
            return false
        }
    }
    
    // MARK: - Workout Set CRUD
    func createWorkoutSet(_ workoutSet: WorkoutSet) -> Int64? {
        guard let db = db else { return nil }
        
        do {
            let insert = workoutSets.insert(
                workoutExerciseId <- workoutSet.workoutExerciseId,
                setNumber <- workoutSet.setNumber,
                weight <- workoutSet.weight,
                reps <- workoutSet.reps,
                isCompleted <- workoutSet.isCompleted,
                completedAtSet <- workoutSet.completedAt
            )
            return try db.run(insert)
        } catch {
            print("Insert workout set error: \(error)")
            return nil
        }
    }
    
    func getWorkoutSets(forWorkoutExerciseId wrkExId: Int64) -> [WorkoutSet] {
        guard let db = db else { return [] }
        
        var result: [WorkoutSet] = []
        
        do {
            let query = workoutSets.filter(workoutExerciseId == wrkExId).order(setNumber.asc)
            for row in try db.prepare(query) {
                let workoutSet = WorkoutSet(
                    id: row[id],
                    workoutExerciseId: row[workoutExerciseId],
                    setNumber: row[setNumber],
                    weight: row[weight],
                    reps: row[reps],
                    isCompleted: row[isCompleted],
                    completedAt: row[completedAtSet]
                )
                result.append(workoutSet)
            }
        } catch {
            print("Get workout sets error: \(error)")
        }
        
        return result
    }
    
    func updateWorkoutSet(_ workoutSet: WorkoutSet) -> Bool {
        guard let db = db, let setId = workoutSet.id else { return false }
        
        do {
            let row = workoutSets.filter(id == setId)
            try db.run(row.update(
                weight <- workoutSet.weight,
                reps <- workoutSet.reps,
                isCompleted <- workoutSet.isCompleted,
                completedAtSet <- workoutSet.completedAt
            ))
            return true
        } catch {
            print("Update workout set error: \(error)")
            return false
        }
    }
    
    func completeWorkoutSet(_ setId: Int64, weight: Double, reps: Int) -> Bool {
        guard let db = db else { return false }
        
        do {
            let row = workoutSets.filter(id == setId)
            try db.run(row.update(
                isCompleted <- true,
                completedAtSet <- Date(),
                self.weight <- weight,
                self.reps <- reps
            ))
            return true
        } catch {
            print("Complete workout set error: \(error)")
            return false
        }
    }
    
    func deleteWorkoutSet(_ setId: Int64) -> Bool {
        guard let db = db else { return false }
        
        do {
            let row = workoutSets.filter(id == setId)
            try db.run(row.delete())
            return true
        } catch {
            print("Delete workout set error: \(error)")
            return false
        }
    }
    
    // MARK: - Active Workout State CRUD
    func getActiveWorkoutState() -> ActiveWorkoutState? {
        guard let db = db else { return nil }
        
        do {
            if let row = try db.pluck(activeWorkout) {
                return ActiveWorkoutState(
                    id: row[id],
                    workoutId: row[workoutId],
                    currentExerciseIndex: row[currentExerciseIndex],
                    currentSetNumber: row[currentSetNumber],
                    timerEndTime: row[timerEndTime],
                    isTimerRunning: row[isTimerRunning],
                    lastSyncedAt: row[lastSyncedAt]
                )
            }
        } catch {
            print("Get active workout state error: \(error)")
        }
        
        return nil
    }
    
    func saveActiveWorkoutState(_ state: ActiveWorkoutState) -> Bool {
        guard let db = db else { return false }
        
        do {
            // Delete existing state
            try db.run(activeWorkout.delete())
            
            // Insert new state
            var insert = activeWorkout.insert(
                currentExerciseIndex <- state.currentExerciseIndex,
                currentSetNumber <- state.currentSetNumber,
                timerEndTime <- state.timerEndTime,
                isTimerRunning <- state.isTimerRunning,
                lastSyncedAt <- state.lastSyncedAt
            )
            if let wId = state.workoutId {
                insert = activeWorkout.insert(
                    self.workoutId <- wId,
                    currentExerciseIndex <- state.currentExerciseIndex,
                    currentSetNumber <- state.currentSetNumber,
                    timerEndTime <- state.timerEndTime,
                    isTimerRunning <- state.isTimerRunning,
                    lastSyncedAt <- state.lastSyncedAt
                )
            }
            try db.run(insert)
            return true
        } catch {
            print("Save active workout state error: \(error)")
            return false
        }
    }
    
    func clearActiveWorkoutState() -> Bool {
        guard let db = db else { return false }
        
        do {
            try db.run(activeWorkout.delete())
            return true
        } catch {
            print("Clear active workout state error: \(error)")
            return false
        }
    }
    
    // MARK: - Workout from Template
    func createWorkoutFromTemplate(_ templateId: Int64, workoutType: WorkoutType) -> Int64? {
        guard getTemplate(byId: templateId) != nil else { return nil }
        
        let workout = Workout(
            templateId: templateId,
            workoutType: workoutType,
            startedAt: Date()
        )
        
        guard let workoutId = createWorkout(workout) else { return nil }
        
        let templateExercisesList = getTemplateExercises(forTemplateId: templateId)
        
        for (index, templateExercise) in templateExercisesList.enumerated() {
            let workoutExercise = WorkoutExercise(
                workoutId: workoutId,
                exerciseId: templateExercise.exerciseId,
                sortOrder: index
            )
            
            if let workoutExerciseId = createWorkoutExercise(workoutExercise) {
                // Create sets based on template defaults
                for setNum in 1...templateExercise.defaultSets {
                    let workoutSet = WorkoutSet(
                        workoutExerciseId: workoutExerciseId,
                        setNumber: setNum,
                        weight: templateExercise.defaultWeight,
                        reps: templateExercise.defaultReps
                    )
                    _ = createWorkoutSet(workoutSet)
                }
            }
        }
        
        return workoutId
    }
    
    func getLastSets(forExerciseId exId: Int64) -> [WorkoutSet] {
        guard let db = db else { return [] }
        
        do {
            // Find the most recent workout that includes this exercise
            let query = workoutExercises
                .join(workouts, on: workoutId == workouts[id])
                .filter(exerciseId == exId)
                .order(workouts[startedAt].desc)
                .limit(1)
            
            if let lastWorkoutExercise = try db.pluck(query) {
                let weId = lastWorkoutExercise[workoutExercises[id]]
                return getWorkoutSets(forWorkoutExerciseId: weId)
            }
        } catch {
            print("Get last sets error: \(error)")
        }
        
        return []
    }
    
    func checkAndSavePR(exerciseId exId: Int64, weight w: Double, reps r: Int) -> Bool {
        guard let db = db else { return false }
        
        let current1RM = PersonalRecord.estimate1RM(weight: w, reps: r)
        if current1RM <= 0 { return false }
        
        do {
            // Get all PRs for this exercise to compare
            let existingPRs = getPersonalRecords(forExerciseId: exId)
            
            // Check if this specific weight/rep combo is better than existing
            // OR if it's a new 1RM record.
            let isNewBestForReps = !existingPRs.contains { $0.reps == r && $0.weight >= w }
            let isNewOverall1RM = existingPRs.allSatisfy { $0.estimated1RM < current1RM }
            
            if isNewBestForReps || isNewOverall1RM {
                _ = createPersonalRecord(PersonalRecord(exerciseId: exId, weight: w, reps: r))
                return true
            }
        } catch {
            print("Check PR error: \(error)")
        }
        
        return false
    }
    
    // MARK: - Statistics
    func getWorkoutCount() -> Int {
        guard let db = db else { return 0 }
        
        do {
            return try db.scalar(workouts.count)
        } catch {
            print("Get workout count error: \(error)")
            return 0
        }
    }
    
    func getCompletedWorkoutCount() -> Int {
        guard let db = db else { return 0 }
        
        do {
            return try db.scalar(workouts.filter(completedAt != nil).count)
        } catch {
            print("Get completed workout count error: \(error)")
            return 0
        }
    }
    
    func getTotalVolume() -> Double {
        guard let db = db else { return 0 }
        
        var totalVolume: Double = 0
        
        do {
            for row in try db.prepare(workoutSets.filter(isCompleted == true)) {
                totalVolume += row[weight] * Double(row[reps])
            }
        } catch {
            print("Get total volume error: \(error)")
        }
        
        return totalVolume
    }
}
