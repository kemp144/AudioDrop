import SwiftUI

struct RecordingControlsView: View {
    @EnvironmentObject var viewModel: RecordingViewModel

    var body: some View {
        VStack(spacing: 16) {
            // Elapsed time (visible during recording)
            if viewModel.recordingState.isRecording {
                VStack(spacing: 4) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(.red)
                            .frame(width: 10, height: 10)
                            .opacity(pulseOpacity)
                            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulseOpacity)

                        Text(viewModel.formattedElapsedTime)
                            .font(.system(.title, design: .monospaced))
                            .fontWeight(.medium)
                            .monospacedDigit()
                            .contentTransition(.numericText())
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(Text("recording.elapsed.label \(viewModel.formattedElapsedTime)",
                                        tableName: nil, bundle: .main,
                                        comment: "Accessibility label for elapsed time"))
            }

            // Record / Stop button
            if viewModel.recordingState.canStartRecording {
                startButton
            } else if viewModel.recordingState.canStopRecording {
                stopButton
            } else {
                // Processing state — show disabled button
                ProgressView()
                    .controlSize(.regular)
                    .padding(8)
            }
        }
    }

    private var startButton: some View {
        Button {
            Task {
                await viewModel.startRecording()
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "record.circle")
                    .font(.title3)
                Text("recording.start", tableName: nil, bundle: .main,
                     comment: "Start Recording button label")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
        .buttonStyle(.borderedProminent)
        .tint(.red)
        .controlSize(.large)
        .disabled(viewModel.recordingMode == .appAudio && viewModel.selectedApp == nil)
        .accessibilityHint(Text("recording.start.hint", tableName: nil, bundle: .main,
                                comment: "Accessibility hint for start recording button"))
    }

    private var stopButton: some View {
        Button {
            Task {
                await viewModel.stopRecording()
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "stop.circle.fill")
                    .font(.title3)
                Text("recording.stop", tableName: nil, bundle: .main,
                     comment: "Stop Recording button label")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
        .buttonStyle(.borderedProminent)
        .tint(.secondary)
        .controlSize(.large)
        .keyboardShortcut(.return, modifiers: .command)
        .accessibilityHint(Text("recording.stop.hint", tableName: nil, bundle: .main,
                                comment: "Accessibility hint for stop recording button"))
    }

    private var pulseOpacity: Double {
        viewModel.recordingState.isRecording ? 0.3 : 1.0
    }
}
