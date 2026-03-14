//
//  SettingsView.swift
//  Dime
//

import SwiftUI
import UserNotifications
import UniformTypeIdentifiers

// MARK: - AppSettings
@Observable
final class AppSettings {
    private let defaults = UserDefaults.standard

    var use24HourTime: Bool {
        get { defaults.bool(forKey: "use24HourTime") }
        set { defaults.set(newValue, forKey: "use24HourTime") }
    }

    var notificationsEnabled: Bool {
        get { defaults.bool(forKey: "notificationsEnabled") }
        set { defaults.set(newValue, forKey: "notificationsEnabled") }
    }
}

// MARK: - SettingsView
struct SettingsView: View {
    @Environment(ItemStore.self) private var store
    @State private var settings = AppSettings()
    @State private var showExportSheet = false
    @State private var showImportPicker = false
    @State private var showImportSuccessAlert = false
    @State private var showImportErrorAlert = false
    @State private var importErrorMessage = ""
    @State private var showClearDataAlert = false
    @State private var showResetSettingsAlert = false
    @State private var showNotificationDeniedAlert = false
    @State private var exportURL: URL?

    private var adaptiveText: Color { .primary }

    var body: some View {
        NavigationStack {
            List {
                generalSection
                notificationsSection
                backupSection
                dataSection
                aboutSection
            }
            .listSectionSpacing(24)
            .scrollIndicators(.hidden)
            .foregroundStyle(adaptiveText)
            .navigationTitle("Settings")
            .onAppear { syncNotificationStatus() }
            .alert("Notifications Disabled", isPresented: $showNotificationDeniedAlert) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Notifications are blocked. Please enable them in iOS Settings → Debt Tracker → Notifications.")
            }
        }
    }

    /// Keep the toggle in sync with what iOS actually granted.
    private func syncNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { notifSettings in
            DispatchQueue.main.async {
                let granted = notifSettings.authorizationStatus == .authorized
                if !granted {
                    settings.notificationsEnabled = false
                }
            }
        }
    }

    // MARK: General
    private var generalSection: some View {
        Section {
            Toggle(isOn: $settings.use24HourTime) {
                Label("24-hour time", systemImage: "clock")
            }
            .foregroundStyle(adaptiveText)
        } header: {
            Text("General")
                .foregroundStyle(adaptiveText)
        } footer: {
            Text("Each debt item has its own currency, which you can set when creating or editing an item.")
                .foregroundStyle(adaptiveText)
        }
    }

    // MARK: Notifications
    private var notificationsSection: some View {
        Section {
            Toggle(isOn: Binding(
                get: { settings.notificationsEnabled },
                set: { newValue in
                    if newValue {
                        requestNotificationPermission()
                    } else {
                        settings.notificationsEnabled = false
                    }
                }
            )) {
                Label("Notifications", systemImage: "bell")
            }
            .foregroundStyle(adaptiveText)
        } header: {
            Text("Notifications")
                .foregroundStyle(adaptiveText)
        } footer: {
            Text(settings.notificationsEnabled
                 ? "You'll get repayment reminders a day before each due date."
                 : "Enable to get repayment reminders.")
                .foregroundStyle(adaptiveText)
        }
    }

    private func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { notifSettings in
            DispatchQueue.main.async {
                switch notifSettings.authorizationStatus {
                case .notDetermined:
                    // First time — ask the user
                    center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                        DispatchQueue.main.async {
                            settings.notificationsEnabled = granted
                        }
                    }
                case .authorized, .provisional, .ephemeral:
                    // Already granted
                    settings.notificationsEnabled = true
                case .denied:
                    // User previously denied — can only change in iOS Settings
                    showNotificationDeniedAlert = true
                @unknown default:
                    break
                }
            }
        }
    }

    // MARK: Backups
    private var backupSection: some View {
        Section {
            Button {
                // TODO: Google Drive sign-in / backup flow
            } label: {
                HStack {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Google Drive")
                                .foregroundStyle(adaptiveText)
                            Text("Auto-sync to the cloud")
                                .font(.caption)
                                .foregroundStyle(Color.secondary)
                        }
                    } icon: {
                        Image(systemName: "externaldrive.connected.to.line.below")
                            .foregroundStyle(.blue)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.secondary)
                }
            }

            Button {
                exportData()
            } label: {
                HStack {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Local backup")
                                .foregroundStyle(adaptiveText)
                            Text("Save a JSON file to your device")
                                .font(.caption)
                                .foregroundStyle(Color.secondary)
                        }
                    } icon: {
                        Image(systemName: "internaldrive")
                            .foregroundStyle(.green)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.secondary)
                }
            }

            Button {
                showImportPicker = true
            } label: {
                HStack {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Import backup")
                                .foregroundStyle(adaptiveText)
                            Text("Restore from a JSON backup file")
                                .font(.caption)
                                .foregroundStyle(Color.secondary)
                        }
                    } icon: {
                        Image(systemName: "square.and.arrow.down")
                            .foregroundStyle(.orange)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.secondary)
                }
            }
        } header: {
            Text("Backups")
                .foregroundStyle(adaptiveText)
        } footer: {
            Text("Google Drive syncs your data to the cloud. Local backup exports a JSON file you can share or save. Import merges a backup with your existing data.")
                .foregroundStyle(adaptiveText)
        }
        .sheet(isPresented: $showExportSheet) {
            if let url = exportURL {
                ShareSheet(url: url)
            }
        }
        .fileImporter(
            isPresented: $showImportPicker,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            importBackup(result: result)
        }
        .alert("Backup imported", isPresented: $showImportSuccessAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your backup was restored successfully.")
        }
        .alert("Import failed", isPresented: $showImportErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(importErrorMessage)
        }
    }

    // MARK: Data
    private var dataSection: some View {
        Section {
            // Clear all data
            Button(role: .destructive) {
                showClearDataAlert = true
            } label: {
                Label("Clear all data", systemImage: "trash")
                    .foregroundStyle(adaptiveText)
            }
            .confirmationDialog(
                "Clear all data?",
                isPresented: $showClearDataAlert,
                titleVisibility: .visible
            ) {
                Button("Delete everything", role: .destructive) {
                    store.clearAll()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will permanently delete all debt items and repayment history. This cannot be undone.")
            }

            // Reset settings
            Button(role: .destructive) {
                showResetSettingsAlert = true
            } label: {
                Label("Reset settings", systemImage: "arrow.counterclockwise")
                    .foregroundStyle(adaptiveText)
            }
            .confirmationDialog(
                "Reset settings?",
                isPresented: $showResetSettingsAlert,
                titleVisibility: .visible
            ) {
                Button("Reset to defaults", role: .destructive) {
                    resetSettings()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will reset all settings to their default values. Your data will not be affected.")
            }
        } header: {
            Text("Data")
                .foregroundStyle(adaptiveText)
        } footer: {
            Text("Clearing data is permanent and cannot be undone.")
                .foregroundStyle(adaptiveText)
        }
    }

    // MARK: About
    private var aboutSection: some View {
        Section {
            LabeledContent("Version") {
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    .foregroundStyle(adaptiveText)
            }
            LabeledContent("App") {
                Text("Debt Tracker")
                    .foregroundStyle(adaptiveText)
            }
        } header: {
            Text("About")
                .foregroundStyle(adaptiveText)
        }
    }

    // MARK: Helpers
    private func exportData() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(store.items) else { return }

        let fileName = "DebtTracker_Export_\(formattedDate()).json"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try? data.write(to: url)
        exportURL = url
        showExportSheet = true
    }

    private func formattedDate() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd_HHmmss"
        return f.string(from: Date())
    }

    private func importBackup(result: Result<[URL], Error>) {
        switch result {
        case .failure(let error):
            importErrorMessage = error.localizedDescription
            showImportErrorAlert = true
        case .success(let urls):
            guard let url = urls.first else { return }
            let accessed = url.startAccessingSecurityScopedResource()
            defer { if accessed { url.stopAccessingSecurityScopedResource() } }

            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let imported = try decoder.decode([RepaymentItem].self, from: data)
                store.merge(imported)
                showImportSuccessAlert = true
            } catch {
                importErrorMessage = "The file could not be read. Make sure it is a valid Debt Tracker backup.\n\n\(error.localizedDescription)"
                showImportErrorAlert = true
            }
        }
    }

    private func resetSettings() {
        settings.use24HourTime = false
        settings.notificationsEnabled = false
    }
}

// MARK: - UIActivityViewController wrapper
struct ShareSheet: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
