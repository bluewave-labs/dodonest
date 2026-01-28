import Foundation
import AppKit
import CoreGraphics

/// Bridging utilities for low-level window and menu bar operations.
enum Bridging {
    /// Options for getting a window list.
    struct WindowListOption: OptionSet {
        let rawValue: Int

        static let menuBarItems = WindowListOption(rawValue: 1 << 0)
        static let activeSpace = WindowListOption(rawValue: 1 << 1)
        static let onScreen = WindowListOption(rawValue: 1 << 2)
    }

    /// Returns an array of window IDs matching the given options.
    static func getWindowList(option: WindowListOption) -> [CGWindowID] {
        var listOption: CGWindowListOption = []

        if option.contains(.onScreen) {
            listOption.insert(.optionOnScreenOnly)
        }

        let windowList = CGWindowListCopyWindowInfo(listOption, kCGNullWindowID) as? [[String: Any]] ?? []

        return windowList.compactMap { window -> CGWindowID? in
            guard let windowID = window[kCGWindowNumber as String] as? CGWindowID else {
                return nil
            }

            if option.contains(.menuBarItems) {
                guard let layer = window[kCGWindowLayer as String] as? Int else {
                    return nil
                }
                // Menu bar items are at specific window levels
                guard layer == Int(CGWindowLevelForKey(.statusWindow)) ||
                      layer == Int(CGWindowLevelForKey(.mainMenuWindow)) ||
                      layer == 25 else { // Status item level
                    return nil
                }
            }

            if option.contains(.activeSpace) {
                guard let isOnScreen = window[kCGWindowIsOnscreen as String] as? Bool, isOnScreen else {
                    return nil
                }
            }

            return windowID
        }
    }

    /// Returns the frame of the window with the given ID.
    static func getWindowFrame(for windowID: CGWindowID) -> CGRect? {
        let windowList = CGWindowListCopyWindowInfo([.optionIncludingWindow], windowID) as? [[String: Any]] ?? []

        guard let window = windowList.first,
              let boundsDict = window[kCGWindowBounds as String] as? [String: Any],
              let x = boundsDict["X"] as? CGFloat,
              let y = boundsDict["Y"] as? CGFloat,
              let width = boundsDict["Width"] as? CGFloat,
              let height = boundsDict["Height"] as? CGFloat else {
            return nil
        }

        return CGRect(x: x, y: y, width: width, height: height)
    }

    /// Returns the owner PID of the window with the given ID.
    static func getWindowOwnerPID(for windowID: CGWindowID) -> pid_t? {
        let windowList = CGWindowListCopyWindowInfo([.optionIncludingWindow], windowID) as? [[String: Any]] ?? []

        guard let window = windowList.first,
              let pid = window[kCGWindowOwnerPID as String] as? pid_t else {
            return nil
        }

        return pid
    }

    /// Returns the owner name of the window with the given ID.
    static func getWindowOwnerName(for windowID: CGWindowID) -> String? {
        let windowList = CGWindowListCopyWindowInfo([.optionIncludingWindow], windowID) as? [[String: Any]] ?? []

        guard let window = windowList.first,
              let name = window[kCGWindowOwnerName as String] as? String else {
            return nil
        }

        return name
    }

    /// Returns whether the window is on screen.
    static func isWindowOnScreen(windowID: CGWindowID) -> Bool {
        let windowList = CGWindowListCopyWindowInfo([.optionIncludingWindow], windowID) as? [[String: Any]] ?? []

        guard let window = windowList.first,
              let isOnScreen = window[kCGWindowIsOnscreen as String] as? Bool else {
            return false
        }

        return isOnScreen
    }

    /// Returns the window level of the window with the given ID.
    static func getWindowLevel(for windowID: CGWindowID) -> Int? {
        let windowList = CGWindowListCopyWindowInfo([.optionIncludingWindow], windowID) as? [[String: Any]] ?? []

        guard let window = windowList.first,
              let level = window[kCGWindowLayer as String] as? Int else {
            return nil
        }

        return level
    }
}
