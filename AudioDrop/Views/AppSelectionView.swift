import SwiftUI

struct AppSelectionView: View {
    @EnvironmentObject var viewModel: RecordingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let app = viewModel.selectedApp {
                HStack(spacing: 10) {
                    if let icon = app.icon {
                        Image(nsImage: icon)
                            .resizable()
                            .frame(width: 32, height: 32)
                            .cornerRadius(6)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(app.name)
                            .font(.body)
                            .fontWeight(.medium)

                        Text("appSelection.appLevel.hint", tableName: nil, bundle: .main,
                             comment: "Hint that audio is captured at the app level")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button {
                        viewModel.showAppPicker = true
                    } label: {
                        Text("appSelection.change", tableName: nil, bundle: .main,
                             comment: "Button to change selected app")
                    }
                    .disabled(!viewModel.recordingState.canStartRecording)
                }
                .padding(12)
                .background(.quaternary.opacity(0.5))
                .cornerRadius(8)
            } else {
                Button {
                    viewModel.showAppPicker = true
                } label: {
                    HStack {
                        Image(systemName: "app.dashed")
                        Text("appSelection.choose", tableName: nil, bundle: .main,
                             comment: "Button to choose an app to record")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.bordered)
                .disabled(!viewModel.recordingState.canStartRecording)
            }
        }
    }
}
