import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var eventMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize services
        _ = MenuBarService.shared

        // Request accessibility permission only if not already granted
        if !AccessibilityManager.shared.isAccessibilityGranted {
            AccessibilityManager.shared.requestAccessibility()
        }

        // Setup menu bar icon if enabled
        if AppSettings.shared.showDodoNestIcon {
            setupStatusItem()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false // Keep running in menu bar
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            // Open main window if no windows are visible
            NSApp.activate(ignoringOtherApps: true)
        }
        return true
    }

    // MARK: - Status Item

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = createMenuBarIcon()
            button.image?.isTemplate = true
            button.action = #selector(togglePopover)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        setupPopover()
        setupEventMonitor()
    }

    private func createMenuBarIcon() -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size, flipped: false) { rect in
            // Draw a simple grid/nest icon
            let path = NSBezierPath()

            // Outer rounded rect
            let outerRect = NSRect(x: 2, y: 2, width: 14, height: 14)
            path.appendRoundedRect(outerRect, xRadius: 3, yRadius: 3)

            // Inner horizontal lines (like a nest pattern)
            path.move(to: NSPoint(x: 4, y: 6))
            path.line(to: NSPoint(x: 14, y: 6))

            path.move(to: NSPoint(x: 4, y: 9))
            path.line(to: NSPoint(x: 14, y: 9))

            path.move(to: NSPoint(x: 4, y: 12))
            path.line(to: NSPoint(x: 14, y: 12))

            NSColor.labelColor.setStroke()
            path.lineWidth = 1.2
            path.stroke()

            return true
        }

        image.isTemplate = true
        return image
    }

    private func setupPopover() {
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 320, height: 400)
        popover?.behavior = .transient
        popover?.animates = true
        popover?.contentViewController = NSHostingController(
            rootView: MenuBarPopoverView()
                .background(Color.dodoBackground)
                .preferredColorScheme(.dark)
        )
    }

    private func setupEventMonitor() {
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if self?.popover?.isShown == true {
                self?.popover?.performClose(nil)
            }
        }
    }

    @objc private func togglePopover(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent

        if event?.type == .rightMouseUp {
            showContextMenu(sender)
        } else {
            if popover?.isShown == true {
                popover?.performClose(nil)
            } else {
                popover?.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }

    private func showContextMenu(_ sender: NSStatusBarButton) {
        // Close popover first if it's open
        if popover?.isShown == true {
            popover?.performClose(nil)
        }

        let menu = NSMenu()

        // Open main window
        let openItem = NSMenuItem(title: "Open DodoNest", action: #selector(openMainWindow), keyEquivalent: "")
        openItem.target = self
        menu.addItem(openItem)

        // Settings
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        // About
        let aboutItem = NSMenuItem(title: "About DodoNest", action: #selector(showAbout), keyEquivalent: "")
        aboutItem.target = self
        menu.addItem(aboutItem)

        menu.addItem(NSMenuItem.separator())

        // Quit
        menu.addItem(NSMenuItem(title: "Quit DodoNest", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }

    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "DodoNest"
        alert.informativeText = "A menu bar organizer for macOS.\n\n© 2024 DodoNest\nMIT License"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    @objc private func openMainWindow() {
        NSApp.activate(ignoringOtherApps: true)
        if let window = NSApp.windows.first(where: { $0.title == "DodoNest" }) {
            window.makeKeyAndOrderFront(nil)
        } else {
            // Open new window
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        }
    }

    @objc private func openSettings() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
