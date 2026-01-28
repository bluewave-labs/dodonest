import Foundation
import AppKit
import CoreGraphics

/// Service for moving menu bar items using CGEvent-based mouse simulation.
/// Requires Accessibility permission to work.
final class MenuBarItemMover {
    static let shared = MenuBarItemMover()

    private init() {}

    // MARK: - Public Methods

    /// Move a menu bar item to insert at a specific position in the list.
    /// - Parameters:
    ///   - sourceName: The name of the item to move
    ///   - index: The insertion index (0 = before first item, items.count = after last item)
    ///   - items: The current ordered list of menu bar items
    /// - Returns: True if the move was successful
    @discardableResult
    func moveItem(named sourceName: String, toInsertAt index: Int, in items: [MenuBarItem]) async -> Bool {
        guard AccessibilityManager.shared.isAccessibilityGranted else {
            print("MenuBarItemMover: Accessibility permission not granted")
            return false
        }

        // Get fresh items from the service to ensure we have current windowIDs
        MenuBarService.shared.refreshItems()
        let freshItems = MenuBarService.shared.items

        guard let sourceItem = freshItems.first(where: { $0.name == sourceName }),
              let sourceFrame = sourceItem.frame else {
            print("MenuBarItemMover: Could not find source item or frame - source: \(sourceName)")
            return false
        }

        // Calculate target X position based on insertion index
        let targetX = calculateTargetX(forInsertionAt: index, in: items, freshItems: freshItems)

        guard let targetX = targetX else {
            print("MenuBarItemMover: Could not calculate target position for index \(index)")
            return false
        }

        print("MenuBarItemMover: Moving '\(sourceName)' from x=\(sourceFrame.midX) to insert at x=\(targetX)")

        let startPoint = CGPoint(x: sourceFrame.midX, y: sourceFrame.midY)
        let endPoint = CGPoint(x: targetX, y: sourceFrame.midY)

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

    // MARK: - Position Calculation

    /// Calculate the target X position for inserting at a specific index.
    /// - Parameters:
    ///   - index: The insertion index
    ///   - items: The ordered list of items as displayed
    ///   - freshItems: Fresh items from the service with current frames
    /// - Returns: The target X coordinate, or nil if it cannot be calculated
    private func calculateTargetX(forInsertionAt index: Int, in items: [MenuBarItem], freshItems: [MenuBarItem]) -> CGFloat? {
        // If inserting at the beginning (index 0)
        if index == 0 {
            // Get the first item and position just before it
            if let firstItem = items.first,
               let freshFirst = freshItems.first(where: { $0.name == firstItem.name }),
               let frame = freshFirst.frame {
                return frame.minX - 5
            }
            return nil
        }

        // If inserting at the end
        if index >= items.count {
            // Get the last item and position just after it
            if let lastItem = items.last,
               let freshLast = freshItems.first(where: { $0.name == lastItem.name }),
               let frame = freshLast.frame {
                return frame.maxX + 5
            }
            return nil
        }

        // Inserting between two items - position at the midpoint between them
        let itemBefore = items[index - 1]
        let itemAfter = items[index]

        guard let freshBefore = freshItems.first(where: { $0.name == itemBefore.name }),
              let freshAfter = freshItems.first(where: { $0.name == itemAfter.name }),
              let frameBefore = freshBefore.frame,
              let frameAfter = freshAfter.frame else {
            return nil
        }

        // Target is the midpoint between the two items
        return (frameBefore.maxX + frameAfter.minX) / 2
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
