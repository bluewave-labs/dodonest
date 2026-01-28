import SwiftUI
import UniformTypeIdentifiers

/// A menu bar item row that can be dragged for reordering.
/// Drop handling is managed at the grid level via DropZoneView.
struct DraggableMenuBarItemRow: View {
    let item: MenuBarItem
    let isDraggedItem: Bool
    var onHideToggle: ((MenuBarItem) -> Void)?

    var body: some View {
        MenuBarItemRow(item: item, showHideButton: true, onHideToggle: onHideToggle)
            .opacity(isDraggedItem ? 0.5 : 1.0)
            .draggable(item.id.uuidString) {
                // Drag preview
                MenuBarItemRow(item: item)
                    .frame(width: 200)
                    .opacity(0.8)
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
            isDraggedItem: false
        )

        DraggableMenuBarItemRow(
            item: MenuBarItem(
                name: "Dragged Item",
                bundleIdentifier: "com.example",
                order: 1,
                isSystemItem: false
            ),
            isDraggedItem: true
        )
    }
    .padding()
    .background(Color.dodoBackground)
    .preferredColorScheme(.dark)
}
