import SwiftUI

struct AppearanceView: View {
    @State private var currentLanguage = L10n.current

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
        .onReceive(NotificationCenter.default.publisher(for: .languageChanged)) { _ in
            currentLanguage = L10n.current
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(L10n.appearance)
                .font(.dodoTitle)
                .foregroundColor(.dodoTextPrimary)

            Text(L10n.customizeMenuBarLooks)
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
                    Text(L10n.appearanceComingSoon)
                        .font(.dodoHeadline)
                        .foregroundColor(.dodoTextPrimary)

                    Text(L10n.customizationFeaturesComingSoon)
                        .font(.dodoBody)
                        .foregroundColor(.dodoTextSecondary)
                }
            }

            Divider()
                .background(Color.dodoBorder.opacity(0.2))

            VStack(alignment: .leading, spacing: 8) {
                featureRow(icon: "arrow.left.and.right", text: L10n.adjustSpacing)
                featureRow(icon: "macbook", text: L10n.notchAwareLayout)
                featureRow(icon: "paintpalette", text: L10n.tintColorsAndThemes)
                featureRow(icon: "shadow", text: L10n.shadowsAndEffects)
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
