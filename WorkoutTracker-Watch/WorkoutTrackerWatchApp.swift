import SwiftUI

@main
struct WorkoutTrackerWatchApp: App {
    @StateObject private var connectivityService = WatchConnectivityService.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(connectivityService)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var connectivityService: WatchConnectivityService
    
    var body: some View {
        VStack {
            if connectivityService.activeWorkoutData != nil {
                WorkoutView()
            } else {
                VStack {
                    Image(systemName: "figure.run")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                    Text("No active workout")
                }
            }
        }
        .padding()
    }
}
