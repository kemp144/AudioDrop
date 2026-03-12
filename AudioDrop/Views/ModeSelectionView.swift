import SwiftUI

struct ModeSelectionView: View {
    @EnvironmentObject var viewModel: RecordingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("mode.label", tableName: nil, bundle: .main,
                 comment: "Label for the recording mode picker")
                .font(.headline)

            Picker(selection: $viewModel.recordingMode) {
                ForEach(RecordingMode.allCases) { mode in
                    Text(mode.displayName).tag(mode)
                }
            } label: {
                EmptyView()
            }
            .pickerStyle(.segmented)
            .disabled(!viewModel.recordingState.canStartRecording)

            Text(viewModel.recordingMode.description)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
