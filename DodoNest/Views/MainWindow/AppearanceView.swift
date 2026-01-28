import SwiftUI

struct AppearanceView: View {
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
            Text("Appearance")
                .font(.dodoTitle)
                .foregroundColor(.dodoTextPrimary)

            Text("Customize how your menu bar looks")
                .font(.dodoBody)
                .foregroundColor(.dodoTextSecondary)
        }
    }

    private var comingSoonCard: some View {
        VStack(alignment: .leading, spacing: DodoNestDimensions.spacing) {
            HStack(spacing: 12) {
                Image(systemName: "paintbrush.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.dodoPrimary)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Appearance options coming soon")
                        .font(.dodoHeadline)
                        .foregroundColor(.dodoTextPrimary)

                    Text("Customization features will be available in a future update.")
                        .font(.dodoBody)
                        .foregroundColor(.dodoTextSecondary)
                }
            }

            Divider()
                .background(Color.dodoBorder.opacity(0.2))

            VStack(alignment: .leading, spacing: 8) {
                featureRow(icon: "arrow.left.and.right", text: "Adjust spacing between menu bar items")
                featureRow(icon: "macbook", text: "Notch-aware layout for MacBook Pro/Air")
                featureRow(icon: "paintpalette", text: "Tint colors and themes")
                featureRow(icon: "shadow", text: "Shadows and visual effects")
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
    AppearanceView()
        .frame(width: 700, height: 500)
        .preferredColorScheme(.dark)
}
