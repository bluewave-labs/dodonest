import Foundation
import AppKit
import CoreGraphics

/// Service for moving menu bar items using CGEvent-based mouse simulation.
/// Requires Accessibility permission to work.
final class MenuBarItemMover {
    static let shared = MenuBarItemMover()

    private init() {}

    // MARK: - Public Methods

    /// Move a menu bar item to swap positions with another item.
    /// - Parameters:
    ///   - sourceName: The name of the item to move
    ///   - targetName: The name of the item to swap with
    /// - Returns: True if the move was successful
    @discardableResult
    func moveItem(named sourceName: String, toPositionOf targetName: String) async -> Bool {
        guard AccessibilityManager.shared.isAccessibilityGranted else {
            print("MenuBarItemMover: Accessibility permission not granted")
            return false
        }

        // Get fresh items from the service to ensure we have current windowIDs
        MenuBarService.shared.refreshItems()
        let freshItems = MenuBarService.shared.items

        guard let sourceItem = freshItems.first(where: { $0.name == sourceName }),
              let targetItem = freshItems.first(where: { $0.name == targetName }) else {
            print("MenuBarItemMover: Could not find items - source: \(sourceName), target: \(targetName)")
            return false
        }

        guard let sourceFrame = sourceItem.frame,
              let targetFrame = targetItem.frame else {
            print("MenuBarItemMover: Could not get frames - source: \(sourceItem.windowID != nil), target: \(targetItem.windowID != nil)")
            return false
        }

        print("MenuBarItemMover: Moving '\(sourceName)' from x=\(sourceFrame.midX) to '\(targetName)' at x=\(targetFrame.midX)")

        let startPoint = CGPoint(x: sourceFrame.midX, y: sourceFrame.midY)
        let endPoint = CGPoint(x: targetFrame.midX, y: targetFrame.midY)

        // Retry up to 3 times
        for attempt in 1...3 {
            let success = await performDragWithCursor(from: startPoint, to: endPoint)

            if success {
                // Wait a bit and check if the item actually moved
                try? await Task.sleep(nanoseconds: 200_000_000) // 200ms
                MenuBarService.shared.refreshItems()

                if let newSourceItem = MenuBarService.shared.items.first(where: { $0.name == sourceName }),
                   let newFrame = newSourceItem.frame {
                    // Check if position changed significantly
                    if abs(newFrame.midX - sourceFrame.midX) > 10 {
                        print("MenuBarItemMover: Move succeeded on attempt \(attempt)")
                        return true
                    }
                }
            }

            print("MenuBarItemMover: Attempt \(attempt) failed, retrying...")
            try? await Task.sleep(nanoseconds: 150_000_000) // 150ms
        }

        print("MenuBarItemMover: All attempts failed")
        return false
    }

    // MARK: - Private Methods

    private func performDragWithCursor(from startPoint: CGPoint, to endPoint: CGPoint) async -> Bool {
        // Save current mouse position
        let originalPosition = NSEvent.mouseLocation
        let screenHeight = NSScreen.main?.frame.height ?? 0

        // Convert to CG coordinates (flip Y)
        let cgStartPoint = CGPoint(x: startPoint.x, y: startPoint.y)
        let cgEndPoint = CGPoint(x: endPoint.x, y: endPoint.y)

        print("MenuBarItemMover: Dragging from \(cgStartPoint) to \(cgEndPoint)")

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
        let steps = 10
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

            try? await Task.sleep(nanoseconds: 30_000_000) // 30ms per step
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
