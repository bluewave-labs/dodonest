import SwiftUI

struct LayoutView: View {
    @State private var searchText = ""
    @State private var items: [MenuBarItem] = []
    @State private var isMovingItem = false
    @State private var movingItemName: String?
    @State private var currentLanguage = L10n.current
    @State private var isHidingItem = false
    @State private var hidingItemName: String?
    @State private var isShowingItem = false

    // Drag and drop insertion state
    @State private var draggedItemID: UUID?
    @State private var insertionIndex: Int?

    private var menuBarService: MenuBarService { MenuBarService.shared }
    private var itemMover: MenuBarItemMover { MenuBarItemMover.shared }
    private var itemHider: MenuBarItemHider { MenuBarItemHider.shared }

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
                hiddenItemsCard
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

            HStack {
                Text(L10n.itemsCurrentlyInMenuBar)
                    .font(.dodoCaption)
                    .foregroundColor(.dodoTextSecondary)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "eye")
                        .font(.system(size: 10))
                    Text(L10n.clickToHideItems)
                        .font(.dodoCaptionSmall)
                }
                .foregroundColor(.dodoTextTertiary)
            }

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
        // Filter out hidden items
        let visibleItems = items.filter { !AppSettings.shared.isItemHidden($0.name) }
        let sortedItems = visibleItems.sorted { item1, item2 in
            let x1 = item1.frame?.minX ?? CGFloat.greatestFiniteMagnitude
            let x2 = item2.frame?.minX ?? CGFloat.greatestFiniteMagnitude
            return x1 < x2
        }

        if searchText.isEmpty {
            return sortedItems
        }

        return sortedItems.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private var hiddenItemsList: [MenuBarItem] {
        items.filter { AppSettings.shared.isItemHidden($0.name) }
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
                            isDraggedItem: draggedItemID == item.id,
                            onHideToggle: handleHideToggle
                        )
                        .onDrag {
                            draggedItemID = item.id
                            return NSItemProvider(object: item.id.uuidString as NSString)
                        }
                        .dropDestination(for: String.self) { droppedItems, _ in
                            guard let droppedItemIDString = droppedItems.first,
                                  let droppedItemID = UUID(uuidString: droppedItemIDString),
                                  droppedItemID != item.id else {
                                return false
                            }

                            // Find the target index (insert before this item)
                            if let targetIndex = filteredItems.firstIndex(where: { $0.id == item.id }) {
                                handleDropAtIndex(targetIndex, draggedID: droppedItemID)
                            }
                            return true
                        } isTargeted: { targeted in
                            if targeted && draggedItemID != item.id {
                                if let targetIndex = filteredItems.firstIndex(where: { $0.id == item.id }) {
                                    insertionIndex = targetIndex
                                }
                            } else if !targeted && insertionIndex == filteredItems.firstIndex(where: { $0.id == item.id }) {
                                insertionIndex = nil
                            }
                        }
                        .overlay(alignment: .leading) {
                            // Show insertion indicator on the left side of targeted item
                            if let targetIndex = filteredItems.firstIndex(where: { $0.id == item.id }),
                               insertionIndex == targetIndex,
                               draggedItemID != item.id {
                                DropIndicatorLine()
                                    .offset(x: -6)
                            }
                        }
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
        .onChange(of: draggedItemID) { _, newValue in
            // Clear insertion index when drag ends
            if newValue == nil {
                insertionIndex = nil
            }
        }
    }

    // MARK: - Drop Handling

    private func handleDropAtIndex(_ index: Int, draggedID: UUID) {
        guard let sourceItem = items.first(where: { $0.id == draggedID }) else {
            draggedItemID = nil
            insertionIndex = nil
            return
        }

        // Find source index in filtered items
        guard let sourceIndex = filteredItems.firstIndex(where: { $0.id == draggedID }) else {
            draggedItemID = nil
            insertionIndex = nil
            return
        }

        // Don't move if dropping at same position or adjacent position (no change)
        if index == sourceIndex || index == sourceIndex + 1 {
            draggedItemID = nil
            insertionIndex = nil
            return
        }

        guard AccessibilityManager.shared.isAccessibilityGranted else {
            draggedItemID = nil
            insertionIndex = nil
            return
        }

        isMovingItem = true
        movingItemName = sourceItem.name

        Task {
            let success = await itemMover.moveItem(
                named: sourceItem.name,
                toInsertAt: index,
                in: filteredItems
            )

            await MainActor.run {
                isMovingItem = false
                movingItemName = nil
                draggedItemID = nil
                insertionIndex = nil

                if success {
                    menuBarService.refreshItems()
                    items = menuBarService.items
                }
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

    // MARK: - Hidden Items Card

    private var hiddenItemsCard: some View {
        VStack(alignment: .leading, spacing: DodoNestDimensions.spacingSmall) {
            HStack {
                Image(systemName: "eye.slash")
                    .foregroundColor(.dodoTextTertiary)

                Text(L10n.hiddenItems)
                    .font(.dodoHeadline)
                    .foregroundColor(.dodoTextPrimary)

                Spacer()

                Text("\(hiddenItemsList.count) \(L10n.items)")
                    .font(.dodoCaption)
                    .foregroundColor(.dodoTextTertiary)
            }

            Text(L10n.itemsHiddenOffScreen)
                .font(.dodoCaption)
                .foregroundColor(.dodoTextSecondary)

            hiddenItemsGrid
        }
        .padding(DodoNestDimensions.cardPadding)
        .background(Color.dodoBackgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: DodoNestDimensions.borderRadiusMedium))
        .overlay(
            RoundedRectangle(cornerRadius: DodoNestDimensions.borderRadiusMedium)
                .stroke(Color.dodoBorder.opacity(0.2), lineWidth: 1)
        )
    }

    private var hiddenItemsGrid: some View {
        Group {
            if hiddenItemsList.isEmpty {
                hiddenItemsEmptyState
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], spacing: DodoNestDimensions.spacingSmall) {
                    ForEach(hiddenItemsList) { item in
                        MenuBarItemRow(item: item, showHideButton: true, onHideToggle: handleHideToggle)
                    }
                }
            }
        }
        .frame(minHeight: 60)
        .padding(DodoNestDimensions.cardPaddingSmall)
        .background(Color.dodoBackgroundTertiary.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: DodoNestDimensions.borderRadius))
        .overlay {
            if isHidingItem {
                hidingOverlay
            }
        }
    }

    private var hiddenItemsEmptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "eye.slash")
                .font(.system(size: 24))
                .foregroundColor(.dodoTextTertiary)

            Text(L10n.noHiddenItems)
                .font(.dodoCaption)
                .foregroundColor(.dodoTextTertiary)

            Text(L10n.clickToHideItems)
                .font(.dodoCaptionSmall)
                .foregroundColor(.dodoTextTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }

    private var hidingOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .clipShape(RoundedRectangle(cornerRadius: DodoNestDimensions.borderRadius))

            VStack(spacing: 12) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))

                Text("\(isShowingItem ? L10n.showingItem : L10n.hidingItem) \(hidingItemName ?? "")...")
                    .font(.dodoSubheadline)
                    .foregroundColor(.white)
            }
        }
    }

    // MARK: - Hide Toggle Handler

    private func handleHideToggle(_ item: MenuBarItem) {
        guard !item.isSystemItem else {
            return
        }

        let isCurrentlyHidden = AppSettings.shared.isItemHidden(item.name)
        isHidingItem = true
        isShowingItem = isCurrentlyHidden
        hidingItemName = item.name

        Task {
            let success: Bool
            if isCurrentlyHidden {
                success = await itemHider.showItem(item)
            } else {
                success = await itemHider.hideItem(item)
            }

            await MainActor.run {
                isHidingItem = false
                isShowingItem = false
                hidingItemName = nil

                if success {
                    menuBarService.refreshItems()
                }
            }
        }
    }
}

#Preview {
    LayoutView()
        .frame(width: 700, height: 600)
        .preferredColorScheme(.dark)
}
