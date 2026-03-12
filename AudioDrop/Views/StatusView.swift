import SwiftUI

struct StatusView: View {
    @EnvironmentObject var viewModel: RecordingViewModel
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 5) {
                statusIcon
                Text(viewModel.recordingState.statusText)
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundStyle(statusColor)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .animation(.easeInOut(duration: 0.2), value: viewModel.recordingState)

            if case .saved(let url) = viewModel.recordingState {
                Button {
                    NSWorkspace.shared.selectFile(url.path, inFileViewerRootedAtPath: url.deletingLastPathComponent().path)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "folder")
                        Text("status.showInFinder", tableName: nil, bundle: .main,
                             comment: "Button to reveal saved file in Finder")
                    }
                    .font(.footnote)
                    .fontWeight(.medium)
                }
                .buttonStyle(.link)
                .accessibilityHint(Text("status.showInFinder.hint", tableName: nil, bundle: .main,
                                        comment: "Accessibility hint for show in Finder button"))
            }
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(borderColor, lineWidth: 1)
        )
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
        case .error:
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
        }
    }

    private var statusColor: Color {
        switch viewModel.recordingState {
        case .error:
            return .red
        case .saved:
            return .green
        case .recording:
            return .primary
        default:
            return .secondary
        }
    }

    private var borderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.06)
    }
}
