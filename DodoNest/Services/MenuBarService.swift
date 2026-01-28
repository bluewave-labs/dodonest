import Foundation
import AppKit
import Observation

// MARK: - Menu Bar Service

@Observable
final class MenuBarService {
    static let shared = MenuBarService()

    // MARK: - Properties

    private(set) var items: [MenuBarItem] = []

    private var refreshTimer: Timer?
    private let persistenceKey = "menuBarItemConfigurations"

    // MARK: - Initialization

    private init() {
        loadPersistedConfiguration()
        startRefreshTimer()
    }

    deinit {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    /// Stop refresh timer (for testing or cleanup)
    func stopRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    // MARK: - Public Methods

    /// Refresh menu bar items from the system
    func refreshItems() {
        let systemItems = fetchSystemMenuBarItems()

        // Merge with persisted configuration
        var updatedItems: [MenuBarItem] = []

        for systemItem in systemItems {
            if let existingItem = items.first(where: { $0.name == systemItem.name || $0.bundleIdentifier == systemItem.bundleIdentifier }) {
                // Keep user's order preferences
                var item = systemItem
                item.order = existingItem.order
                updatedItems.append(item)
            } else {
                // New item
                var item = systemItem
                item.order = updatedItems.count
                updatedItems.append(item)
            }
        }

        items = updatedItems
        persistConfiguration()

        NotificationCenter.default.post(name: .menuBarLayoutChanged, object: nil)
    }

    /// Search items by name
    func searchItems(_ query: String) -> [MenuBarItem] {
        guard !query.isEmpty else { return items }
        return items.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    // MARK: - Private Methods

    private func startRefreshTimer() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.refreshItems()
        }
        refreshItems()
    }

    private func fetchSystemMenuBarItems() -> [MenuBarItem] {
        var items: [MenuBarItem] = []

        // Get menu bar windows using CGWindowListCopyWindowInfo
        let windowList = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] ?? []

        for window in windowList {
            guard let layer = window[kCGWindowLayer as String] as? Int,
                  layer == kCGStatusWindowLevel || layer == kCGMainMenuWindowLevel else {
                continue
            }

            guard let ownerName = window[kCGWindowOwnerName as String] as? String,
                  let windowID = window[kCGWindowNumber as String] as? CGWindowID else {
                continue
            }

            // Skip system UI elements we don't want to manage
            let skipList = ["Window Server", "Dock", "SystemUIServer"]
            if skipList.contains(ownerName) && ownerName != "SystemUIServer" {
                continue
            }

            let bundleID = window[kCGWindowOwnerPID as String].flatMap { pid -> String? in
                guard let pidValue = pid as? pid_t else { return nil }
                let app = NSRunningApplication(processIdentifier: pidValue)
                return app?.bundleIdentifier
            }

            let isSystem = ownerName == "SystemUIServer" || ownerName == "Control Center"

            // Try to get icon
            var icon: NSImage?
            if let pid = window[kCGWindowOwnerPID as String] as? pid_t,
               let app = NSRunningApplication(processIdentifier: pid) {
                icon = app.icon
            }

            let ownerPID = window[kCGWindowOwnerPID as String] as? pid_t

            let item = MenuBarItem(
                name: ownerName,
                bundleIdentifier: bundleID,
                order: items.count,
                isSystemItem: isSystem,
                icon: icon,
                windowID: windowID,
                ownerPID: ownerPID
            )

            // Avoid duplicates
            if !items.contains(where: { $0.name == item.name }) {
                items.append(item)
            }
        }

        return items
    }

    private func persistConfiguration() {
        let configs = items.map { item -> [String: Any] in
            return [
                "id": item.id.uuidString,
                "name": item.name,
                "bundleIdentifier": item.bundleIdentifier ?? "",
                "order": item.order,
                "isSystemItem": item.isSystemItem
            ]
        }
        UserDefaults.standard.set(configs, forKey: persistenceKey)
    }

    private func loadPersistedConfiguration() {
        guard let configs = UserDefaults.standard.array(forKey: persistenceKey) as? [[String: Any]] else {
            return
        }

        items = configs.compactMap { config -> MenuBarItem? in
            guard let idString = config["id"] as? String,
                  let id = UUID(uuidString: idString),
                  let name = config["name"] as? String,
                  let order = config["order"] as? Int,
                  let isSystemItem = config["isSystemItem"] as? Bool else {
                return nil
            }

            let bundleIdentifier = config["bundleIdentifier"] as? String
            return MenuBarItem(
                id: id,
                name: name,
                bundleIdentifier: bundleIdentifier?.isEmpty == true ? nil : bundleIdentifier,
                order: order,
                isSystemItem: isSystemItem
            )
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let menuBarLayoutChanged = Notification.Name("menuBarLayoutChanged")
    static let navigateTo = Notification.Name("navigateTo")
}
