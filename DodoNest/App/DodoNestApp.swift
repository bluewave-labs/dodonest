import SwiftUI
import ServiceManagement

@main
struct DodoNestApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup("DodoNest", id: "main") {
            MainWindowView()
                .frame(minWidth: 700, minHeight: 500)
                .background(Color.dodoBackground)
                .preferredColorScheme(.dark)
        }
        .windowStyle(.automatic)
        .windowToolbarStyle(.unifiedCompact)
        .defaultSize(width: 900, height: 600)
        .commands {
            CommandGroup(replacing: .newItem) { }

            CommandMenu("View") {
                Button("Layout") {
                    NotificationCenter.default.post(name: .navigateTo, object: NavigationItem.layout)
                }
                .keyboardShortcut("1", modifiers: .command)

                Button("Appearance") {
                    NotificationCenter.default.post(name: .navigateTo, object: NavigationItem.appearance)
                }
                .keyboardShortcut("2", modifiers: .command)

                Button("Hotkeys") {
                    NotificationCenter.default.post(name: .navigateTo, object: NavigationItem.hotkeys)
                }
                .keyboardShortcut("3", modifiers: .command)

                Button("Settings") {
                    NotificationCenter.default.post(name: .navigateTo, object: NavigationItem.settings)
                }
                .keyboardShortcut("4", modifiers: .command)
            }

            CommandMenu("Actions") {
                Button("Refresh menu bar items") {
                    MenuBarService.shared.refreshItems()
                }
                .keyboardShortcut("r", modifiers: .command)
            }
        }

        Settings {
            SettingsWindowView()
        }
    }
}

// MARK: - Navigation Item

enum NavigationItem: String, CaseIterable, Identifiable {
    case layout
    case appearance
    case hotkeys
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .layout: return "Layout"
        case .appearance: return "Appearance"
        case .hotkeys: return "Hotkeys"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .layout: return "menubar.rectangle"
        case .appearance: return "paintbrush.fill"
        case .hotkeys: return "keyboard"
        case .settings: return "gearshape"
        }
    }
}
