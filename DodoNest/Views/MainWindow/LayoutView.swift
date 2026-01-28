import SwiftUI

struct LayoutView: View {
    @State private var searchText = ""
    @State private var items: [MenuBarItem] = []
    @State private var isMovingItem = false
    @State private var movingItemName: String?
    @State private var currentLanguage = L10n.current

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
        .onReceive(NotificationCenter.default.publisher(for: .languageChanged)) { _ in
            currentLanguage = L10n.current
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(L10n.menuBarLayout)
                    .font(.dodoTitle)
                    .foregroundColor(.dodoTextPrimary)

                InfoTooltip(text: L10n.dragItemInstruction)
            }

            Text(L10n.dragAndDropToRearrange)
                .font(.dodoBody)
                .foregroundColor(.dodoTextSecondary)
        }
    }

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

                Text(L10n.menuBarItems)
                    .font(.dodoHeadline)
                    .foregroundColor(.dodoTextPrimary)

                Spacer()

                Text("\(filteredItems.count) \(L10n.items)")
                    .font(.dodoCaption)
                    .foregroundColor(.dodoTextTertiary)
            }

            Text(L10n.itemsCurrentlyInMenuBar)
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
                Text(L10n.howToReorderItems)
                    .font(.dodoSubheadline)
                    .foregroundColor(.dodoTextPrimary)
            }

            VStack(alignment: .leading, spacing: 8) {
                instructionRow(
                    number: "1",
                    text: L10n.dragItemInstruction
                )
                instructionRow(
                    number: "2",
                    text: L10n.commandDragInstruction
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

                Text("\(L10n.movingItem) \(movingItemName ?? "")...")
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

            Text(searchText.isEmpty ? L10n.noMenuBarItemsDetected : L10n.noItemsMatchSearch)
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
