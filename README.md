# DodoNest - macOS Menu Bar Organizer

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![macOS](https://img.shields.io/badge/macOS-14.0+-blue.svg)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org/)

A native macOS application for organizing and rearranging your menu bar items. Built with SwiftUI for macOS 14+.

## Features

- **Visual menu bar layout** - See all your menu bar items in one place
- **Drag-and-drop reordering** - Drag items onto each other to swap their positions in the actual menu bar
- **Search functionality** - Quickly find any menu bar item by name
- **Real-time sync** - Items are displayed in their actual menu bar order
- **Menu bar icon** - Quick access from the menu bar
- **Multilingual support** - English, Turkish, German, French, Spanish, Japanese, Chinese

## How it works

DodoNest uses macOS Accessibility APIs to simulate Command+drag operations, which is the native way to rearrange menu bar items. When you drag an item onto another in the app, DodoNest physically moves your cursor and performs the drag operation to swap their positions.

### Requirements

- **Accessibility permission** - Required to move menu bar items
- macOS 14.0 (Sonoma) or later

## Installation

### Homebrew

```bash
brew tap bluewave-labs/dodonest
brew install --cask dodonest
```

The Homebrew formula automatically removes the quarantine attribute, so the app will open without issues.

### Manual installation

1. Download the latest DMG from [Releases](https://github.com/bluewave-labs/dodonest/releases)
2. Open the DMG and drag DodoNest to Applications
3. Right-click and select "Open" on first launch, or run:

```bash
xattr -cr /Applications/DodoNest.app
```

## Usage

### Reordering menu bar items

**Method 1: Using DodoNest app**
1. Open DodoNest from the menu bar or Applications
2. Go to the Layout tab
3. Drag an item and drop it onto another item
4. The items will swap positions in your actual menu bar

**Method 2: Direct manipulation**
- Hold **⌘ Command** and drag items directly in your menu bar

### Settings

- **Launch at login** - Start DodoNest automatically when you log in
- **Show menu bar icon** - Toggle the DodoNest icon in the menu bar

## Building from source

### Prerequisites

- Xcode 15.0 or later
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (for generating project)

### Build steps

```bash
# Install dependencies
make install-dependencies

# Generate Xcode project
make generate-project

# Build the app
make build

# Run the app
make run
```

### Creating a release

```bash
make release VERSION=1.0.0
```

This creates a DMG in the `build/` directory.

## Project structure

```
DodoNest/
├── App/
│   ├── DodoNestApp.swift          # Main app entry point
│   └── AppDelegate.swift          # Menu bar management
├── Views/
│   ├── MainWindow/                # Main window views
│   │   ├── MainWindowView.swift
│   │   ├── LayoutView.swift       # Menu bar item layout
│   │   ├── AppearanceView.swift   # Coming soon
│   │   ├── HotkeysView.swift      # Coming soon
│   │   └── GeneralSettingsView.swift
│   ├── MenuBar/
│   │   └── MenuBarPopoverView.swift
│   ├── Components/
│   │   ├── MenuBarItemRow.swift
│   │   └── DraggableMenuBarItemRow.swift
│   └── Permissions/
│       └── AccessibilityPermissionView.swift
├── Services/
│   ├── MenuBarService.swift       # Menu bar item detection
│   ├── MenuBarItemMover.swift     # CGEvent-based item movement
│   └── AccessibilityManager.swift
├── Models/
│   ├── MenuBarItem.swift
│   └── AppSettings.swift
├── Utilities/
│   ├── Bridging.swift             # Window management APIs
│   ├── DesignSystem.swift         # Colors, fonts, styles
│   ├── Localization.swift         # Multilingual support
│   └── Extensions.swift
└── Resources/
    └── Assets.xcassets
```

## Comparison with alternatives

| Feature | **DodoNest** | **Bartender** | **Ice** |
|---------|-------------|---------------|---------|
| **Price** | Free (Open Source) | $16 | Free (Open Source) |
| **Reorder items** | ✅ Drag-and-drop | ✅ | ✅ |
| **Hide items** | Coming soon | ✅ | ✅ |
| **Hotkeys** | Coming soon | ✅ | ✅ |
| **Menu bar styling** | Coming soon | ✅ | ❌ |
| **macOS version** | 14.0+ | 11.0+ | 14.0+ |
| **Open source** | ✅ MIT License | ❌ | ✅ MIT License |

## Roadmap

- [ ] Hide/show menu bar items
- [ ] Global hotkeys
- [ ] Menu bar appearance customization
- [ ] Notch-aware layouts

## Design system

- **Primary color**: #13715B (Green)
- **Background**: #0F1419 (Dark)
- **Text primary**: #F9FAFB
- **Border radius**: 4px
- **Button height**: 34px

## License

MIT License - see [LICENSE](LICENSE) for details.

## Acknowledgments

- Inspired by [Bartender](https://www.macbartender.com/) and [Ice](https://github.com/jordanbaird/Ice)
- Part of the Dodo app family (DodoPulse, DodoTidy, DodoNest)

## Support

If you find DodoNest useful, consider:
- ⭐ Starring the repository
- 🐛 Reporting bugs
- 💡 Suggesting features
- 🤝 Contributing code
