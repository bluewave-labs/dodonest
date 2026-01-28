import SwiftUI

struct MenuBarPopoverView: View {
    @State private var menuBarService = MenuBarService.shared
    @State private var searchText = ""

    var body: some View {
        VStack(spacing: 0) {
            searchBar
            itemsList
            footer
        }
        .frame(width: 320, height: 400)
        .background(Color.dodoBackground)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.dodoTextTertiary)

            TextField("Search menu bar items...", text: $searchText)
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
            Text("\(menuBarService.items.count) items")
                .font(.dodoCaption)
                .foregroundColor(.dodoTextTertiary)

            Spacer()

            Button {
                openMainWindow()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "gear")
                    Text("Settings")
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
