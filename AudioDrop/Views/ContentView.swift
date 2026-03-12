import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: RecordingViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HeaderView()

            Divider()

            ScrollView {
                VStack(spacing: 20) {
                    // Mode Selection
                    ModeSelectionView()

                    // App Picker (when in app audio mode)
                    if viewModel.recordingMode == .appAudio {
                        AppSelectionView()
                    }

                    // Format Picker
                    FormatSelectionView()

                    Divider()

                    // Recording Controls
                    RecordingControlsView()

                    // Status
                    StatusView()
                }
                .padding(24)
            }
        }
        .frame(width: 400)
        .frame(minHeight: 480)
        .sheet(isPresented: $viewModel.showPermissionExplanation) {
            PermissionExplanationView()
        }
        .sheet(isPresented: $viewModel.showAppPicker) {
            AppPickerView()
        }
        .task {
            viewModel.permissionManager.refreshPermissionStateOnLaunch()
        }
    }
}

// MARK: - Header

private struct HeaderView: View {
    var body: some View {
        VStack(spacing: 4) {
            Text("AudioDrop")
                .font(.title2)
                .fontWeight(.semibold)

            Text("record.subtitle", tableName: nil, bundle: .main,
                 comment: "App subtitle shown below the title")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Format Selection

private struct FormatSelectionView: View {
    @EnvironmentObject var viewModel: RecordingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("format.label", tableName: nil, bundle: .main,
                 comment: "Label for the audio format picker")
                .font(.headline)

            Picker(selection: $viewModel.audioFormat) {
                ForEach(AudioFormat.allCases) { format in
                    Text(format.displayName).tag(format)
                }
            } label: {
                EmptyView()
            }
            .pickerStyle(.segmented)
            .disabled(!viewModel.recordingState.canStartRecording)

            Text("save.summary", tableName: nil, bundle: .main,
                 comment: "Summary that recordings are saved after recording stops")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
