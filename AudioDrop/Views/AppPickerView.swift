import SwiftUI

struct AppPickerView: View {
    @EnvironmentObject var viewModel: RecordingViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private var filteredApps: [RecordableApp] {
        if searchText.isEmpty {
            return viewModel.availableApps
        }
        return viewModel.availableApps.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("appPicker.title", tableName: nil, bundle: .main,
                     comment: "App picker title")
                    .font(.headline)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("appPicker.close", tableName: nil, bundle: .main,
                                         comment: "Close app picker button label"))
            }
            .padding(16)

            // Hint text
            Text("appPicker.hint", tableName: nil, bundle: .main,
                 comment: "Hint about app-level audio capture")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)

            Divider()

            // Search
            TextField(String(localized: "appPicker.search", defaultValue: "Search apps…"), text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(12)

            // App list
            if filteredApps.isEmpty {
                Spacer()
                Text("appPicker.noApps", tableName: nil, bundle: .main,
                     comment: "Message when no apps are found")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                List(filteredApps) { app in
                    AppRowView(app: app, isSelected: viewModel.selectedApp == app) {
                        viewModel.selectApp(app)
                        dismiss()
                    }
                }
                .listStyle(.plain)
            }
        }
        .frame(width: 350, height: 450)
        .task {
            await viewModel.refreshAvailableApps()
        }
    }
}

// MARK: - App Row

private struct AppRowView: View {
    let app: RecordableApp
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 10) {
                if let icon = app.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .frame(width: 28, height: 28)
                        .cornerRadius(6)
                } else {
                    Image(systemName: "app.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundStyle(.secondary)
                }

                Text(app.name)
                    .font(.body)
                    .lineLimit(1)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.blue)
                }
            }
            .contentShape(Rectangle())
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
