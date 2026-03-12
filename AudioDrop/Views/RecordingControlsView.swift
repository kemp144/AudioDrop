import SwiftUI

struct RecordingControlsView: View {
    @EnvironmentObject var viewModel: RecordingViewModel
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 12) {
            if viewModel.recordingState.isRecording {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color(red: 0.91, green: 0.26, blue: 0.21))
                        .frame(width: 8, height: 8)
                        .opacity(pulseOpacity)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulseOpacity)

                    Text(viewModel.formattedElapsedTime)
                        .font(.system(.headline, design: .monospaced))
                        .fontWeight(.semibold)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(nsColor: .controlBackgroundColor))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(borderColor, lineWidth: 1)
                )
                .accessibilityElement(children: .combine)
                .accessibilityLabel(Text("recording.elapsed.label \(viewModel.formattedElapsedTime)",
                                        tableName: nil, bundle: .main,
                                        comment: "Accessibility label for elapsed time"))
            }

            if viewModel.recordingState.canStartRecording {
                startButton
            } else if viewModel.recordingState.canStopRecording {
                stopButton
            } else {
                ProgressView()
                    .controlSize(.regular)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var startButton: some View {
        Button {
            Task {
                await viewModel.startRecording()
            }
        } label: {
            HStack(spacing: 7) {
                Image(systemName: "record.circle")
                    .font(.body)
                Text("recording.start", tableName: nil, bundle: .main,
                     comment: "Start Recording button label")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 11)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
        .background(
            Capsule(style: .continuous)
                .fill(Color(red: 0.18, green: 0.45, blue: 0.94))
        )
        .accessibilityHint(Text("recording.start.hint", tableName: nil, bundle: .main,
                                comment: "Accessibility hint for start recording button"))
    }

    private var stopButton: some View {
        Button {
            Task {
                await viewModel.stopRecording()
            }
        } label: {
            HStack(spacing: 7) {
                Image(systemName: "stop.circle.fill")
                    .font(.body)
                Text("recording.stop", tableName: nil, bundle: .main,
                     comment: "Stop Recording button label")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 11)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
        .background(
            Capsule(style: .continuous)
                .fill(Color.black.opacity(0.85))
        )
        .keyboardShortcut(.return, modifiers: .command)
        .accessibilityHint(Text("recording.stop.hint", tableName: nil, bundle: .main,
                                comment: "Accessibility hint for stop recording button"))
    }

    private var pulseOpacity: Double {
        viewModel.recordingState.isRecording ? 0.3 : 1.0
    }

    private var borderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.06)
    }
}
