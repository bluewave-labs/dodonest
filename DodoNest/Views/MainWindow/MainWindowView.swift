import SwiftUI

struct MainWindowView: View {
    @State private var selectedItem: NavigationItem = .layout
    @State private var menuBarService = MenuBarService.shared

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            detailView
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateTo)) { notification in
            if let item = notification.object as? NavigationItem {
                selectedItem = item
            }
        }
    }

    private var sidebar: some View {
        VStack(spacing: 0) {
            // Logo / App header
            HStack(spacing: 10) {
                Image(nsImage: NSApp.applicationIconImage ?? NSImage())
                    .resizable()
                    .frame(width: 32, height: 32)
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                Text("DodoNest")
                    .font(.dodoTitle)
                    .foregroundColor(.dodoTextPrimary)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)

            // Navigation items
            ScrollView {
                VStack(spacing: 4) {
                    ForEach(NavigationItem.allCases) { item in
                        SidebarButton(
                            item: item,
                            isSelected: selectedItem == item,
                            action: {
                                selectedItem = item
                            }
                        )
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 16)
            }

            Spacer()
        }
        .frame(minWidth: 200, idealWidth: 220, maxWidth: 260)
        .background(Color.dodoBackgroundSecondary)
    }

    @ViewBuilder
    private var detailView: some View {
        switch selectedItem {
        case .layout:
            LayoutView()
        case .appearance:
            AppearanceView()
        case .hotkeys:
            HotkeysView()
        case .settings:
            GeneralSettingsView()
        }
    }
}

// MARK: - Sidebar Button

struct SidebarButton: View {
    let item: NavigationItem
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: item.icon)
                    .font(.system(size: 16))
                    .frame(width: 20)
                    .scaleEffect(isSelected ? 1.1 : 1.0)

                Text(item.title)
                    .font(.dodoBody)

                Spacer()

                // Show indicator when selected
                if isSelected {
                    Circle()
                        .fill(Color.dodoPrimary)
                        .frame(width: 6, height: 6)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .foregroundColor(isSelected ? .dodoPrimary : (isHovering ? .dodoTextPrimary : .dodoTextSecondary))
            .background(
                RoundedRectangle(cornerRadius: DodoNestDimensions.borderRadiusMedium)
                    .fill(isSelected ? Color.dodoPrimary.opacity(0.15) : (isHovering ? Color.dodoBackgroundTertiary : Color.clear))
            )
            .animation(.easeInOut(duration: 0.15), value: isSelected)
            .animation(.easeInOut(duration: 0.1), value: isHovering)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.1)) {
                isHovering = hovering
            }
        }
    }
}

#Preview {
    MainWindowView()
        .frame(width: 900, height: 600)
        .preferredColorScheme(.dark)
}
