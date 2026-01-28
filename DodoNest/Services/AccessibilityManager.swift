import Foundation
import AppKit
import ApplicationServices
import Combine

/// Manager for handling Accessibility permissions required for menu bar item manipulation.
final class AccessibilityManager: ObservableObject {
    static let shared = AccessibilityManager()

    /// Whether accessibility access is currently granted.
    @Published var isAccessibilityGranted: Bool = false

    /// Timer for checking accessibility status.
    private var checkTimer: Timer?

    private init() {
        isAccessibilityGranted = AXIsProcessTrusted()
        startMonitoring()
    }

    deinit {
        checkTimer?.invalidate()
    }

    // MARK: - Public Methods

    /// Checks if accessibility access is granted.
    func checkAccessibility() {
        let trusted = AXIsProcessTrusted()
        DispatchQueue.main.async { [weak self] in
            if self?.isAccessibilityGranted != trusted {
                self?.isAccessibilityGranted = trusted
            }
        }
    }

    /// Requests accessibility access by showing the system prompt.
    /// Returns true if access was already granted.
    @discardableResult
    func requestAccessibility() -> Bool {
        // This will show the system prompt asking for accessibility access
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        let trusted = AXIsProcessTrustedWithOptions(options)
        DispatchQueue.main.async { [weak self] in
            self?.isAccessibilityGranted = trusted
        }
        return trusted
    }

    /// Opens System Settings to the Accessibility pane.
    func openAccessibilitySettings() {
        // macOS 14+ Privacy & Security > Accessibility
        if let url = URL(string: "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }

    /// Starts monitoring for accessibility permission changes.
    func startMonitoring() {
        checkTimer?.invalidate()
        checkTimer = Timer(timeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkAccessibility()
        }
        RunLoop.main.add(checkTimer!, forMode: .common)
    }

    /// Stops monitoring for accessibility permission changes.
    func stopMonitoring() {
        checkTimer?.invalidate()
        checkTimer = nil
    }
}
