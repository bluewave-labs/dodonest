import Foundation
import AppKit

// MARK: - Menu Bar Item

struct MenuBarItem: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var bundleIdentifier: String?
    var order: Int
    var isSystemItem: Bool

    // Not persisted - runtime only
    var icon: NSImage?
    var windowID: CGWindowID?
    var ownerPID: pid_t?

    enum CodingKeys: String, CodingKey {
        case id, name, bundleIdentifier, order, isSystemItem
    }

    /// The current frame of the item in the menu bar.
    var frame: CGRect? {
        guard let windowID = windowID else { return nil }
        return Bridging.getWindowFrame(for: windowID)
    }

    /// Whether the item is currently on screen.
    var isOnScreen: Bool {
        guard let windowID = windowID else { return false }
        return Bridging.isWindowOnScreen(windowID: windowID)
    }

    init(
        id: UUID = UUID(),
        name: String,
        bundleIdentifier: String? = nil,
        order: Int = 0,
        isSystemItem: Bool = false,
        icon: NSImage? = nil,
        windowID: CGWindowID? = nil,
        ownerPID: pid_t? = nil
    ) {
        self.id = id
        self.name = name
        self.bundleIdentifier = bundleIdentifier
        self.order = order
        self.isSystemItem = isSystemItem
        self.icon = icon
        self.windowID = windowID
        self.ownerPID = ownerPID
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: MenuBarItem, rhs: MenuBarItem) -> Bool {
        lhs.id == rhs.id
    }
}
