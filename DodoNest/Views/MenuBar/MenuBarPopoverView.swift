import SwiftUI

struct MenuBarPopoverView: View {
    @State private var menuBarService = MenuBarService.shared
    @State private var searchText = ""
    @State private var currentLanguage = L10n.current

    var body: some View {
        VStack(spacing: 0) {
            searchBar
            itemsList
            footer
        }
        .frame(width: 320, height: 400)
        .background(Color.dodoBackground)
        .onReceive(NotificationCenter.default.publisher(for: .languageChanged)) { _ in
            currentLanguage = L10n.current
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.dodoTextTertiary)

            TextField(L10n.searchMenuBarItems, text: $searchText)
                .textFieldStyle(.plain)
                .foregroundColor(.dodoTextPrimary)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.dodoTextTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(DodoNestDimensions.cardPaddingSmall)
        .background(Color.dodoBackgroundSecondary)
    }

    // MARK: - Items List

    private var itemsList: some View {
        ScrollView {
            LazyVStack(spacing: 2) {
                ForEach(filteredItems) { item in
                    PopoverItemRow(item: item)
                }
            }
            .padding(DodoNestDimensions.spacingSmall)
        }
    }

    private var filteredItems: [MenuBarItem] {
        let allItems = menuBarService.items
        if searchText.isEmpty {
            return allItems
        }
        return allItems.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    // MARK: - Footer

    private var footer: some View {
        HStack {
            Text("\(menuBarService.items.count) \(L10n.items)")
                .font(.dodoCaption)
                .foregroundColor(.dodoTextTertiary)

            Spacer()

            // Language menu
            Menu {
                ForEach(Language.allCases, id: \.rawValue) { lang in
                    Button {
                        L10n.current = lang
                    } label: {
                        HStack {
                            Text("\(lang.flag) \(lang.displayName)")
                            if lang == currentLanguage {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(currentLanguage.flag)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 8))
                }
                .font(.dodoCaption)
                .foregroundColor(.dodoTextSecondary)
            }
            .menuStyle(.borderlessButton)
            .fixedSize()

            Button {
                openMainWindow()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "gear")
                    Text(L10n.settings)
                }
                .font(.dodoCaption)
                .foregroundColor(.dodoTextSecondary)
            }
            .buttonStyle(.plain)
        }
        .padding(DodoNestDimensions.cardPaddingSmall)
        .background(Color.dodoBackgroundSecondary)
    }

    private func openMainWindow() {
        NSApp.activate(ignoringOtherApps: true)
        if let window = NSApp.windows.first(where: { $0.title == "DodoNest" }) {
            window.makeKeyAndOrderFront(nil)
        }
    }
}

// MARK: - Popover Item Row

struct PopoverItemRow: View {
    let item: MenuBarItem

    @State private var isHovered = false

    var body: some View {
        HStack(spacing: DodoNestDimensions.spacingSmall) {
            // Icon
            if let icon = item.icon {
                Image(nsImage: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
            } else {
                Image(systemName: item.isSystemItem ? "gearshape" : "app")
                    .foregroundColor(.dodoTextSecondary)
                    .frame(width: 20, height: 20)
            }

            // Name
            Text(item.name)
                .font(.dodoBody)
                .foregroundColor(.dodoTextPrimary)

            Spacer()
        }
        .padding(.horizontal, DodoNestDimensions.cardPaddingSmall)
        .padding(.vertical, 8)
        .background(isHovered ? Color.dodoBackgroundTertiary : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: DodoNestDimensions.borderRadius))
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

#Preview {
    MenuBarPopoverView()
        .preferredColorScheme(.dark)
}
