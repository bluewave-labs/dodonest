import Foundation
import AppKit
import CoreGraphics

/// Utilities for mouse cursor operations.
enum MouseCursor {
    /// The current location of the mouse cursor in CoreGraphics coordinates.
    static var location: CGPoint? {
        CGEvent(source: nil)?.location
    }

    /// Hides the mouse cursor.
    static func hide() {
        CGDisplayHideCursor(CGMainDisplayID())
    }

    /// Shows the mouse cursor.
    static func show() {
        CGDisplayShowCursor(CGMainDisplayID())
    }

    /// Moves the mouse cursor to the given point.
    static func warp(to point: CGPoint) {
        CGWarpMouseCursorPosition(point)
    }

    /// Moves the cursor to the given point and generates a mouse moved event.
    static func move(to point: CGPoint) {
        warp(to: point)

        // Post a mouse moved event to update the cursor position in the event system
        if let event = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: point, mouseButton: .left) {
            event.post(tap: .cghidEventTap)
        }
    }
}
