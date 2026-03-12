import SwiftUI

struct StatusView: View {
    @EnvironmentObject var viewModel: RecordingViewModel

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                statusIcon
                Text(viewModel.recordingState.statusText)
                    .font(.callout)
                    .foregroundStyle(statusColor)
            }
            .animation(.easeInOut(duration: 0.2), value: viewModel.recordingState)

            // Show saved file path
            if case .saved(let url) = viewModel.recordingState {
                Button {
                    NSWorkspace.shared.selectFile(url.path, inFileViewerRootedAtPath: url.deletingLastPathComponent().path)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "folder")
                        Text("status.showInFinder", tableName: nil, bundle: .main,
                             comment: "Button to reveal saved file in Finder")
                    }
                    .font(.caption)
                }
                .buttonStyle(.link)
                .accessibilityHint(Text("status.showInFinder.hint", tableName: nil, bundle: .main,
                                        comment: "Accessibility hint for show in Finder button"))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var statusIcon: some View {
        switch viewModel.recordingState {
        case .idle:
            Image(systemName: "checkmark.circle")
                .foregroundStyle(.secondary)
        case .preparingToRecord, .stopping, .saving:
            ProgressView()
                .controlSize(.small)
        case .recording:
            Image(systemName: "waveform")
                .foregroundStyle(.red)
                .symbolEffect(.variableColor.iterative, isActive: true)
        case .saved:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        case .permissionRequired:
            Image(systemName: "lock.shield")
                .foregroundStyle(.orange)
        case .error:
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
        }
    }

    private var statusColor: Color {
        switch viewModel.recordingState {
        case .error:
            return .red
        case .permissionRequired:
            return .orange
        case .saved:
            return .green
        case .recording:
            return .primary
        default:
            return .secondary
        }
    }
}
