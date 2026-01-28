import SwiftUI

struct MenuBarItemRow: View {
    let item: MenuBarItem

    var body: some View {
        HStack(spacing: DodoNestDimensions.spacingSmall) {
            // Icon
            if let icon = item.icon {
                Image(nsImage: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: DodoNestDimensions.menuBarIconSize, height: DodoNestDimensions.menuBarIconSize)
            } else {
                Image(systemName: item.isSystemItem ? "gearshape.fill" : "app.fill")
                    .foregroundColor(.dodoTextSecondary)
                    .frame(width: DodoNestDimensions.menuBarIconSize, height: DodoNestDimensions.menuBarIconSize)
            }

            // Name
            Text(item.name)
                .font(.dodoBody)
                .foregroundColor(.dodoTextPrimary)
                .lineLimit(1)

            Spacer()

            // System badge
            if item.isSystemItem {
                Text("System")
                    .font(.dodoCaptionSmall)
                    .foregroundColor(.dodoTextTertiary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.dodoBackgroundTertiary)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }

            }
        .padding(DodoNestDimensions.cardPaddingSmall)
        .frame(height: DodoNestDimensions.menuBarItemHeight)
        .background(Color.dodoBackgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: DodoNestDimensions.borderRadius))
        .overlay(
            RoundedRectangle(cornerRadius: DodoNestDimensions.borderRadius)
                .stroke(Color.dodoBorder.opacity(0.15), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 8) {
        MenuBarItemRow(item: MenuBarItem(
            name: "CleanShot X",
            bundleIdentifier: "com.cleanshot",
            order: 0,
            isSystemItem: false
        ))

        MenuBarItemRow(item: MenuBarItem(
            name: "Control Center",
            bundleIdentifier: nil,
            order: 1,
            isSystemItem: true
        ))
    }
    .padding()
    .background(Color.dodoBackground)
    .preferredColorScheme(.dark)
}
