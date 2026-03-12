import SwiftUI

@main
struct AudioDropApp: App {
    @StateObject private var viewModel = RecordingViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 420, height: 520)
    }
}
