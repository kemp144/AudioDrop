import SwiftUI

struct PermissionExplanationView: View {
    @EnvironmentObject var viewModel: RecordingViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            // Icon
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 48))
                .foregroundStyle(.blue)
                .padding(.top, 8)

            // Title
            Text("permission.title", tableName: nil, bundle: .main,
                 comment: "Permission explanation title")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            // Explanation
            VStack(alignment: .leading, spacing: 12) {
                explanationRow(
                    icon: "speaker.wave.2",
                    text: String(localized: "permission.explanation.audio",
                                 defaultValue: "AudioDrop needs Screen Recording permission to capture the audio playing on your Mac.")
                )
                explanationRow(
                    icon: "desktopcomputer",
                    text: String(localized: "permission.explanation.local",
                                 defaultValue: "Your recordings stay on your Mac. Nothing is uploaded or shared.")
                )
                explanationRow(
                    icon: "person.slash",
                    text: String(localized: "permission.explanation.noAccount",
                                 defaultValue: "No account required. No data collected.")
                )
                explanationRow(
                    icon: "arrow.counterclockwise",
                    text: String(localized: "permission.explanation.restart",
                                 defaultValue: "After granting permission, you may need to restart AudioDrop for changes to take effect.")
                )
            }
            .padding(.horizontal, 8)

            Spacer()

            // Actions
            VStack(spacing: 12) {
                Button {
                    Task {
                        await viewModel.requestScreenRecordingPermission()
                    }
                } label: {
                    Text(viewModel.shouldPromptForPermission ? "permission.continue" : "permission.openSettings",
                         tableName: nil,
                         bundle: .main,
                         comment: "Primary permission action")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button {
                    viewModel.openScreenRecordingSettings()
                } label: {
                    Text("permission.openSettings", tableName: nil, bundle: .main,
                         comment: "Button to open Screen Recording settings")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Button {
                    Task {
                        await viewModel.recheckPermission()
                        if viewModel.permissionManager.hasScreenRecordingPermission {
                            dismiss()
                        }
                    }
                } label: {
                    Text("permission.recheck", tableName: nil, bundle: .main,
                         comment: "Button to recheck Screen Recording permission")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
        }
        .padding(24)
        .frame(width: 380, height: 500)
    }

    private func explanationRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(width: 24)

            Text(text)
                .font(.callout)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
