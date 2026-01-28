import Foundation
import AppKit

// MARK: - Notch Info

struct NotchInfo {
    let hasNotch: Bool
    let notchRect: CGRect?
    let notchWidth: CGFloat
    let safeAreaLeft: CGFloat
    let safeAreaRight: CGFloat
    let screenWidth: CGFloat
    let menuBarHeight: CGFloat

    static let noNotch = NotchInfo(
        hasNotch: false,
        notchRect: nil,
        notchWidth: 0,
        safeAreaLeft: 0,
        safeAreaRight: 0,
        screenWidth: NSScreen.main?.frame.width ?? 0,
        menuBarHeight: NSApplication.shared.mainMenu?.menuBarHeight ?? 24
    )
}

// MARK: - Notch Detector

final class NotchDetector {
    static let shared = NotchDetector()

    private init() {}

    /// Detect notch information for the main screen
    func detectNotch() -> NotchInfo {
        guard let screen = NSScreen.main else {
            return .noNotch
        }

        let screenWidth = screen.frame.width
        let menuBarHeight = NSApplication.shared.mainMenu?.menuBarHeight ?? 24

        // macOS 12+ provides auxiliaryTopLeftArea and auxiliaryTopRightArea
        // These represent the safe areas on either side of the notch
        if #available(macOS 12.0, *) {
            if let topLeftArea = screen.auxiliaryTopLeftArea,
               let topRightArea = screen.auxiliaryTopRightArea {
                // Calculate notch dimensions
                let notchLeft = topLeftArea.maxX
                let notchRight = topRightArea.minX
                let notchWidth = notchRight - notchLeft

                // Only consider it a notch if it's a reasonable size (150-300px)
                if notchWidth > 150 && notchWidth < 350 {
                    let notchRect = CGRect(
                        x: notchLeft,
                        y: screen.frame.height - menuBarHeight,
                        width: notchWidth,
                        height: menuBarHeight
                    )

                    return NotchInfo(
                        hasNotch: true,
                        notchRect: notchRect,
                        notchWidth: notchWidth,
                        safeAreaLeft: topLeftArea.width,
                        safeAreaRight: topRightArea.width,
                        screenWidth: screenWidth,
                        menuBarHeight: menuBarHeight
                    )
                }
            }
        }

        // Fallback: Use screen model detection for known notched Macs
        if let modelIdentifier = getModelIdentifier() {
            if isKnownNotchedMac(modelIdentifier) {
                // Standard notch width is approximately 204 points
                let notchWidth: CGFloat = 204
                let notchLeft = (screenWidth - notchWidth) / 2

                let notchRect = CGRect(
                    x: notchLeft,
                    y: screen.frame.height - menuBarHeight,
                    width: notchWidth,
                    height: menuBarHeight
                )

                return NotchInfo(
                    hasNotch: true,
                    notchRect: notchRect,
                    notchWidth: notchWidth,
                    safeAreaLeft: notchLeft,
                    safeAreaRight: notchLeft,
                    screenWidth: screenWidth,
                    menuBarHeight: menuBarHeight
                )
            }
        }

        return NotchInfo(
            hasNotch: false,
            notchRect: nil,
            notchWidth: 0,
            safeAreaLeft: screenWidth,
            safeAreaRight: 0,
            screenWidth: screenWidth,
            menuBarHeight: menuBarHeight
        )
    }

    /// Check if a point is within the notch area
    func isPointInNotch(_ point: CGPoint) -> Bool {
        let info = detectNotch()
        guard info.hasNotch, let notchRect = info.notchRect else {
            return false
        }
        return notchRect.contains(point)
    }

    /// Get the safe X range for menu bar items (avoiding notch)
    func getSafeXRange() -> (left: CGFloat, right: CGFloat) {
        let info = detectNotch()
        if info.hasNotch, let notchRect = info.notchRect {
            // Return the ranges on either side of the notch
            return (notchRect.minX, notchRect.maxX)
        }
        // No notch - entire width is safe
        return (0, info.screenWidth)
    }

    // MARK: - Private Helpers

    private func getModelIdentifier() -> String? {
        var size = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        var model = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.model", &model, &size, nil, 0)
        return String(cString: model)
    }

    private func isKnownNotchedMac(_ model: String) -> Bool {
        // MacBook Pro models with notch (2021 and later)
        let notchedModels = [
            "MacBookPro18,1", "MacBookPro18,2", "MacBookPro18,3", "MacBookPro18,4", // 2021 14" and 16"
            "Mac14,5", "Mac14,6", "Mac14,9", "Mac14,10", // 2023 14" and 16"
            "Mac15,3", "Mac15,6", "Mac15,7", "Mac15,8", "Mac15,9", "Mac15,10", "Mac15,11", // M3 Pro/Max
            "MacBookAir15,1", // M3 MacBook Air 15"
            "Mac15,12", "Mac15,13", // M3 MacBook Air
        ]

        return notchedModels.contains { model.hasPrefix($0) }
    }
}
