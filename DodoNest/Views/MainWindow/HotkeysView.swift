import SwiftUI

struct HotkeysView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DodoNestDimensions.spacingLarge) {
                header
                comingSoonCard

                Spacer()
            }
            .padding(DodoNestDimensions.cardPaddingLarge)
        }
        .background(Color.dodoBackground)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Hotkeys")
                .font(.dodoTitle)
                .foregroundColor(.dodoTextPrimary)

            Text("Keyboard shortcuts for quick access")
                .font(.dodoBody)
                .foregroundColor(.dodoTextSecondary)
        }
    }

    private var comingSoonCard: some View {
        VStack(alignment: .leading, spacing: DodoNestDimensions.spacing) {
            HStack(spacing: 12) {
                Image(systemName: "keyboard")
                    .font(.system(size: 32))
                    .foregroundColor(.dodoPrimary)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Hotkeys coming soon")
                        .font(.dodoHeadline)
                        .foregroundColor(.dodoTextPrimary)

                    Text("Global keyboard shortcuts will be available in a future update when hiding features are implemented.")
                        .font(.dodoBody)
                        .foregroundColor(.dodoTextSecondary)
                }
            }

            Divider()
                .background(Color.dodoBorder.opacity(0.2))

            VStack(alignment: .leading, spacing: 8) {
                featureRow(icon: "eye.slash", text: "Toggle hidden items visibility")
                featureRow(icon: "menubar.dock.rectangle", text: "Show/hide the DodoNest bar")
                featureRow(icon: "command", text: "Customizable key combinations")
            }
        }
        .padding(DodoNestDimensions.cardPadding)
        .background(Color.dodoBackgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: DodoNestDimensions.borderRadiusMedium))
        .overlay(
            RoundedRectangle(cornerRadius: DodoNestDimensions.borderRadiusMedium)
                .stroke(Color.dodoBorder.opacity(0.2), lineWidth: 1)
        )
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: DodoNestDimensions.spacingSmall) {
            Image(systemName: icon)
                .foregroundColor(.dodoTextTertiary)
                .frame(width: 20)

            Text(text)
                .font(.dodoBody)
                .foregroundColor(.dodoTextTertiary)
        }
    }
}

#Preview {
    HotkeysView()
        .frame(width: 700, height: 500)
        .preferredColorScheme(.dark)
}
