import Foundation
import AppKit
import CoreGraphics

/// Service for hiding/showing menu bar items by moving them off-screen.
/// Uses the same CGEvent-based mouse simulation as MenuBarItemMover.
final class MenuBarItemHider {
    static let shared = MenuBarItemHider()

    /// The X position to move hidden items to (off-screen left)
    private let hiddenXPosition: CGFloat = -100

    private init() {}

    // MARK: - Public Methods

    /// Hide a menu bar item by moving it off-screen to the left.
    /// - Parameter item: The menu bar item to hide
    /// - Returns: True if the hide operation was successful
    @discardableResult
    func hideItem(_ item: MenuBarItem) async -> Bool {
        guard AccessibilityManager.shared.isAccessibilityGranted else {
            print("MenuBarItemHider: Accessibility permission not granted")
            return false
        }

        guard !item.isSystemItem else {
            print("MenuBarItemHider: Cannot hide system item '\(item.name)'")
            return false
        }

        // Get fresh item data
        MenuBarService.shared.refreshItems()
        guard let freshItem = MenuBarService.shared.items.first(where: { $0.name == item.name }),
              let currentFrame = freshItem.frame else {
            print("MenuBarItemHider: Could not find item or frame for '\(item.name)'")
            return false
        }

        // Store original position before hiding
        let originalX = currentFrame.midX

        print("MenuBarItemHider: Hiding '\(item.name)' from x=\(originalX)")

        let startPoint = CGPoint(x: currentFrame.midX, y: currentFrame.midY)
        let endPoint = CGPoint(x: hiddenXPosition, y: currentFrame.midY)

        // Perform the drag to hide
        let success = await performDragWithCursor(from: startPoint, to: endPoint)

        if success {
            // Update persistence
            AppSettings.shared.setItemHidden(item.name, hidden: true)

            // Store original position in MenuBarService
            MenuBarService.shared.setOriginalPosition(for: item.name, position: originalX)

            print("MenuBarItemHider: Successfully hid '\(item.name)'")
            return true
        }

        print("MenuBarItemHider: Failed to hide '\(item.name)'")
        return false
    }

    /// Show a hidden menu bar item by restoring it to its original position.
    /// - Parameter item: The menu bar item to show
    /// - Returns: True if the show operation was successful
    @discardableResult
    func showItem(_ item: MenuBarItem) async -> Bool {
        guard AccessibilityManager.shared.isAccessibilityGranted else {
            print("MenuBarItemHider: Accessibility permission not granted")
            return false
        }

        // Get the stored original position
        guard let originalX = MenuBarService.shared.getOriginalPosition(for: item.name) else {
            print("MenuBarItemHider: No original position stored for '\(item.name)'")
            // Try to restore to a reasonable position (center-right of screen)
            let screenWidth = NSScreen.main?.frame.width ?? 1440
            return await showItemAt(item, targetX: screenWidth - 100)
        }

        return await showItemAt(item, targetX: originalX)
    }

    /// Show a hidden item at a specific X position
    private func showItemAt(_ item: MenuBarItem, targetX: CGFloat) async -> Bool {
        // Get fresh item data - the item may be off-screen
        MenuBarService.shared.refreshItems()

        // For hidden items, we need to find them even if they're off-screen
        // The window should still exist, just at a negative X position
        guard let freshItem = MenuBarService.shared.items.first(where: { $0.name == item.name }),
              let currentFrame = freshItem.frame else {
            print("MenuBarItemHider: Could not find item or frame for '\(item.name)'")
            return false
        }

        print("MenuBarItemHider: Showing '\(item.name)' from x=\(currentFrame.midX) to x=\(targetX)")

        let startPoint = CGPoint(x: currentFrame.midX, y: currentFrame.midY)
        let endPoint = CGPoint(x: targetX, y: currentFrame.midY)

        // Perform the drag to show
        let success = await performDragWithCursor(from: startPoint, to: endPoint)

        if success {
            // Update persistence
            AppSettings.shared.setItemHidden(item.name, hidden: false)

            // Clear stored original position
            MenuBarService.shared.clearOriginalPosition(for: item.name)

            print("MenuBarItemHider: Successfully showed '\(item.name)'")
            return true
        }

        print("MenuBarItemHider: Failed to show '\(item.name)'")
        return false
    }

    /// Toggle the visibility of a menu bar item.
    /// - Parameter item: The menu bar item to toggle
    /// - Returns: True if the operation was successful
    @discardableResult
    func toggleItemVisibility(_ item: MenuBarItem) async -> Bool {
        if AppSettings.shared.isItemHidden(item.name) {
            return await showItem(item)
        } else {
            return await hideItem(item)
        }
    }

    // MARK: - Private Methods

    /// Perform a Command+drag operation to move a menu bar item.
    /// This is the same technique used by MenuBarItemMover.
    private func performDragWithCursor(from startPoint: CGPoint, to endPoint: CGPoint) async -> Bool {
        // Save current mouse position
        let originalPosition = NSEvent.mouseLocation
        let screenHeight = NSScreen.main?.frame.height ?? 0

        // Convert to CG coordinates
        let cgStartPoint = CGPoint(x: startPoint.x, y: startPoint.y)
        let cgEndPoint = CGPoint(x: endPoint.x, y: endPoint.y)

        print("MenuBarItemHider: Dragging from \(cgStartPoint) to \(cgEndPoint)")

        // Move cursor to start position
        CGWarpMouseCursorPosition(cgStartPoint)
        try? await Task.sleep(nanoseconds: 50_000_000) // 50ms

        // Press Command key
        guard let cmdDown = CGEvent(keyboardEventSource: nil, virtualKey: 0x37, keyDown: true) else {
            return false
        }
        cmdDown.post(tap: .cgSessionEventTap)
        try? await Task.sleep(nanoseconds: 30_000_000) // 30ms

        // Mouse down
        guard let mouseDown = CGEvent(
            mouseEventSource: nil,
            mouseType: .leftMouseDown,
            mouseCursorPosition: cgStartPoint,
            mouseButton: .left
        ) else {
            return false
        }
        mouseDown.flags = .maskCommand
        mouseDown.post(tap: .cgSessionEventTap)
        try? await Task.sleep(nanoseconds: 50_000_000) // 50ms

        // Drag in steps
        let steps = 15
        for i in 1...steps {
            let progress = CGFloat(i) / CGFloat(steps)
            let currentX = cgStartPoint.x + (cgEndPoint.x - cgStartPoint.x) * progress
            let currentY = cgStartPoint.y + (cgEndPoint.y - cgStartPoint.y) * progress
            let currentPoint = CGPoint(x: currentX, y: currentY)

            // Move cursor
            CGWarpMouseCursorPosition(currentPoint)

            // Post drag event
            guard let dragEvent = CGEvent(
                mouseEventSource: nil,
                mouseType: .leftMouseDragged,
                mouseCursorPosition: currentPoint,
                mouseButton: .left
            ) else {
                continue
            }
            dragEvent.flags = .maskCommand
            dragEvent.post(tap: .cgSessionEventTap)

            try? await Task.sleep(nanoseconds: 25_000_000) // 25ms per step
        }

        // Final position
        CGWarpMouseCursorPosition(cgEndPoint)
        try? await Task.sleep(nanoseconds: 50_000_000) // 50ms

        // Mouse up
        guard let mouseUp = CGEvent(
            mouseEventSource: nil,
            mouseType: .leftMouseUp,
            mouseCursorPosition: cgEndPoint,
            mouseButton: .left
        ) else {
            return false
        }
        mouseUp.flags = .maskCommand
        mouseUp.post(tap: .cgSessionEventTap)
        try? await Task.sleep(nanoseconds: 30_000_000) // 30ms

        // Release Command key
        guard let cmdUp = CGEvent(keyboardEventSource: nil, virtualKey: 0x37, keyDown: false) else {
            return false
        }
        cmdUp.post(tap: .cgSessionEventTap)
        try? await Task.sleep(nanoseconds: 50_000_000) // 50ms

        // Restore original mouse position
        let cgOriginalPosition = CGPoint(x: originalPosition.x, y: screenHeight - originalPosition.y)
        CGWarpMouseCursorPosition(cgOriginalPosition)

        return true
    }
}
