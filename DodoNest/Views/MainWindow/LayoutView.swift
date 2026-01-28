import SwiftUI

struct LayoutView: View {
    @State private var searchText = ""
    @State private var items: [MenuBarItem] = []
    @State private var isMovingItem = false
    @State private var movingItemName: String?

    private var menuBarService: MenuBarService { MenuBarService.shared }
    private var itemMover: MenuBarItemMover { MenuBarItemMover.shared }

    var body: some View {
        VStack(alignment: .leading, spacing: DodoNestDimensions.spacing) {
            header
            AccessibilityBanner()
            searchBar
            sectionsView
        }
        .padding(DodoNestDimensions.cardPaddingLarge)
        .background(Color.dodoBackground)
        .onAppear {
            items = menuBarService.items
            AccessibilityManager.shared.checkAccessibility()
        }
        .onReceive(NotificationCenter.default.publisher(for: .menuBarLayoutChanged)) { _ in
            items = menuBarService.items
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Menu bar layout")
                    .font(.dodoTitle)
                    .foregroundColor(.dodoTextPrimary)

                InfoTooltip(text: "Drag items to reorder them. DodoNest will move them in your actual menu bar.")
            }

            Text("Drag and drop to rearrange your menu bar items")
                .font(.dodoBody)
                .foregroundColor(.dodoTextSecondary)
        }
    }

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
        .clipShape(RoundedRectangle(cornerRadius: DodoNestDimensions.borderRadius))
        .overlay(
            RoundedRectangle(cornerRadius: DodoNestDimensions.borderRadius)
                .stroke(Color.dodoBorder.opacity(0.2), lineWidth: 1)
        )
    }

    private var sectionsView: some View {
        ScrollView {
            VStack(spacing: DodoNestDimensions.spacingLarge) {
                dragInstructionsCard
                menuBarItemsCard
            }
        }
    }

    private var menuBarItemsCard: some View {
        VStack(alignment: .leading, spacing: DodoNestDimensions.spacingSmall) {
            HStack {
                Image(systemName: "menubar.rectangle")
                    .foregroundColor(.dodoPrimary)

                Text("Menu bar items")
                    .font(.dodoHeadline)
                    .foregroundColor(.dodoTextPrimary)

                Spacer()

                Text("\(filteredItems.count) items")
                    .font(.dodoCaption)
                    .foregroundColor(.dodoTextTertiary)
            }

            Text("Items currently in your menu bar")
                .font(.dodoCaption)
                .foregroundColor(.dodoTextSecondary)

            itemsGrid
        }
        .padding(DodoNestDimensions.cardPadding)
        .background(Color.dodoBackgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: DodoNestDimensions.borderRadiusMedium))
        .overlay(
            RoundedRectangle(cornerRadius: DodoNestDimensions.borderRadiusMedium)
                .stroke(Color.dodoBorder.opacity(0.2), lineWidth: 1)
        )
    }

    private var dragInstructionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "hand.draw")
                    .foregroundColor(.dodoPrimary)
                Text("How to reorder menu bar items")
                    .font(.dodoSubheadline)
                    .foregroundColor(.dodoTextPrimary)
            }

            VStack(alignment: .leading, spacing: 8) {
                instructionRow(
                    number: "1",
                    text: "Drag an item above onto another item to swap their positions"
                )
                instructionRow(
                    number: "2",
                    text: "Or hold ⌘ Command and drag items directly in your actual menu bar"
                )
            }
        }
        .padding(DodoNestDimensions.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.dodoBackgroundSecondary.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: DodoNestDimensions.borderRadiusMedium))
        .overlay(
            RoundedRectangle(cornerRadius: DodoNestDimensions.borderRadiusMedium)
                .stroke(Color.dodoBorder.opacity(0.1), lineWidth: 1)
        )
    }

    private func instructionRow(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(number)
                .font(.dodoCaption)
                .fontWeight(.semibold)
                .foregroundColor(.dodoPrimary)
                .frame(width: 18, height: 18)
                .background(Color.dodoPrimary.opacity(0.15))
                .clipShape(Circle())

            Text(text)
                .font(.dodoCaption)
                .foregroundColor(.dodoTextSecondary)
        }
    }

    private var filteredItems: [MenuBarItem] {
        // Sort by actual X position in menu bar (leftmost first)
        // Items without frames go to the end
        let allItems = items.sorted { item1, item2 in
            let x1 = item1.frame?.minX ?? CGFloat.greatestFiniteMagnitude
            let x2 = item2.frame?.minX ?? CGFloat.greatestFiniteMagnitude
            return x1 < x2
        }

        if searchText.isEmpty {
            return allItems
        }

        return allItems.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private var itemsGrid: some View {
        Group {
            if filteredItems.isEmpty {
                emptyStateView
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], spacing: DodoNestDimensions.spacingSmall) {
                    ForEach(filteredItems) { item in
                        DraggableMenuBarItemRow(
                            item: item,
                            items: $items,
                            isMovingItem: $isMovingItem,
                            movingItemName: $movingItemName
                        )
                    }
                }
            }
        }
        .frame(minHeight: 60)
        .padding(DodoNestDimensions.cardPaddingSmall)
        .background(Color.dodoBackgroundTertiary.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: DodoNestDimensions.borderRadius))
        .overlay {
            if isMovingItem {
                movingOverlay
            }
        }
    }

    private var movingOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .clipShape(RoundedRectangle(cornerRadius: DodoNestDimensions.borderRadius))

            VStack(spacing: 12) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))

                Text("Moving \(movingItemName ?? "item")...")
                    .font(.dodoSubheadline)
                    .foregroundColor(.white)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "menubar.rectangle")
                .font(.system(size: 24))
                .foregroundColor(.dodoTextTertiary)

            Text(searchText.isEmpty ? "No menu bar items detected" : "No items match your search")
                .font(.dodoCaption)
                .foregroundColor(.dodoTextTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }
}

#Preview {
    LayoutView()
        .frame(width: 700, height: 600)
        .preferredColorScheme(.dark)
}
