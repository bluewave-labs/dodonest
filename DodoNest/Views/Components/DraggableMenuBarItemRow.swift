import SwiftUI
import UniformTypeIdentifiers

struct DraggableMenuBarItemRow: View {
    let item: MenuBarItem
    @Binding var items: [MenuBarItem]
    @Binding var isMovingItem: Bool
    @Binding var movingItemName: String?

    @State private var isDragging = false
    @State private var isDropTarget = false

    var body: some View {
        MenuBarItemRow(item: item)
            .opacity(isDragging ? 0.5 : 1.0)
            .overlay {
                if isDropTarget {
                    RoundedRectangle(cornerRadius: DodoNestDimensions.borderRadius)
                        .stroke(Color.dodoPrimary, lineWidth: 2)
                }
            }
            .draggable(item.id.uuidString) {
                // Drag preview
                MenuBarItemRow(item: item)
                    .frame(width: 200)
                    .opacity(0.8)
            }
            .dropDestination(for: String.self) { droppedItems, _ in
                guard let droppedItemIDString = droppedItems.first,
                      let droppedItemID = UUID(uuidString: droppedItemIDString),
                      let sourceItem = items.first(where: { $0.id == droppedItemID }),
                      sourceItem.id != item.id else {
                    return false
                }

                // Perform the actual movement in the menu bar
                performMove(sourceItem: sourceItem, targetItem: item)
                return true
            } isTargeted: { targeted in
                isDropTarget = targeted
            }
            .onDrag {
                isDragging = true
                return NSItemProvider(object: item.id.uuidString as NSString)
            }
    }

    private func performMove(sourceItem: MenuBarItem, targetItem: MenuBarItem) {
        guard AccessibilityManager.shared.isAccessibilityGranted else {
            return
        }

        isMovingItem = true
        movingItemName = sourceItem.name

        Task {
            let success = await MenuBarItemMover.shared.moveItem(
                named: sourceItem.name,
                toPositionOf: targetItem.name
            )

            await MainActor.run {
                isMovingItem = false
                movingItemName = nil

                if success {
                    // Refresh items to get updated positions
                    MenuBarService.shared.refreshItems()
                }
            }
        }
    }

}

#Preview {
    VStack(spacing: 8) {
        DraggableMenuBarItemRow(
            item: MenuBarItem(
                name: "CleanShot X",
                bundleIdentifier: "com.cleanshot",
                order: 0,
                isSystemItem: false
            ),
            items: .constant([]),
            isMovingItem: .constant(false),
            movingItemName: .constant(nil)
        )
    }
    .padding()
    .background(Color.dodoBackground)
    .preferredColorScheme(.dark)
}
