import Foundation
import ServiceManagement
import Observation

// MARK: - App Settings

@Observable
final class AppSettings {
    static let shared = AppSettings()

    // MARK: - General Settings

    var launchAtLogin: Bool {
        didSet {
            UserDefaults.standard.set(launchAtLogin, forKey: "launchAtLogin")
            updateLaunchAtLogin()
        }
    }

    var showDodoNestIcon: Bool {
        didSet { UserDefaults.standard.set(showDodoNestIcon, forKey: "showDodoNestIcon") }
    }

    // MARK: - Onboarding

    var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding") }
    }

    // MARK: - Initialization

    private init() {
        // Load settings from UserDefaults with defaults
        self.launchAtLogin = UserDefaults.standard.object(forKey: "launchAtLogin") as? Bool ?? false
        self.showDodoNestIcon = UserDefaults.standard.object(forKey: "showDodoNestIcon") as? Bool ?? true
        self.hasCompletedOnboarding = UserDefaults.standard.object(forKey: "hasCompletedOnboarding") as? Bool ?? false

        // Sync launch at login state with system on startup
        syncLaunchAtLoginState()
    }

    // MARK: - Methods

    private func updateLaunchAtLogin() {
        do {
            if launchAtLogin {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to update launch at login: \(error.localizedDescription)")
        }
    }

    private func syncLaunchAtLoginState() {
        let systemState = SMAppService.mainApp.status == .enabled
        if UserDefaults.standard.bool(forKey: "launchAtLogin") != systemState {
            UserDefaults.standard.set(systemState, forKey: "launchAtLogin")
        }
    }

    func resetToDefaults() {
        launchAtLogin = false
        showDodoNestIcon = true
    }
}
