import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: RecordingViewModel
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 16) {
                HeaderView()
                SurfaceCard {
                    SourceView()
                }
                SurfaceCard {
                    FormatSelectionView()
                }
                RecordingControlsView()
                StatusView()
                Spacer(minLength: 0)
            }
        }
        .padding(18)
        .frame(width: 368)
        .frame(minHeight: 432)
    }

    private var backgroundColor: Color {
        if colorScheme == .dark {
            return Color(nsColor: .windowBackgroundColor)
        }

        return Color(nsColor: NSColor(calibratedRed: 0.96, green: 0.97, blue: 0.99, alpha: 1))
    }
}

private struct HeaderView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("AudioDrop")
                .font(.system(size: 24, weight: .semibold, design: .default))

            Text("record.subtitle", tableName: nil, bundle: .main,
                 comment: "App subtitle shown below the title")
                .font(.headline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 12)
        .padding(.bottom, 6)
        .frame(maxWidth: .infinity)
    }
}

private struct SurfaceCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(borderColor, lineWidth: 1)
        )
        .shadow(color: shadowColor, radius: 12, x: 0, y: 6)
    }

    private var borderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.06)
    }

    private var shadowColor: Color {
        colorScheme == .dark ? .clear : Color.black.opacity(0.04)
    }
}

private struct SourceView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Source")
                .font(.headline)

            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "speaker.wave.3.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(red: 0.18, green: 0.45, blue: 0.94))
                    .frame(width: 40, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(iconBackground)
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text("System Audio")
                        .font(.headline)
                        .fontWeight(.semibold)

                    Text("Records the audio currently playing on your Mac.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)
            }

            Text("Local-only. Choose where to save after you stop recording.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    private var iconBackground: Color {
        colorScheme == .dark
            ? Color.accentColor.opacity(0.22)
            : Color(red: 0.90, green: 0.94, blue: 1.0)
    }
}

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
                 comment: "Summary below the audio format picker")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
