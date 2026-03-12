import SwiftUI

@main
struct SonicDropletApp: App {
    @StateObject private var viewModel = RecordingViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 368, height: 432)
    }
}
