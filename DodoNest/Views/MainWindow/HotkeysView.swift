import SwiftUI

struct HotkeysView: View {
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
            Text(L10n.hotkeys)
                .font(.dodoTitle)
                .foregroundColor(.dodoTextPrimary)

            Text(L10n.keyboardShortcutsDescription)
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
                    Text(L10n.hotkeysComingSoon)
                        .font(.dodoHeadline)
                        .foregroundColor(.dodoTextPrimary)

                    Text(L10n.hotkeysWhenHidingFeatures)
                        .font(.dodoBody)
                        .foregroundColor(.dodoTextSecondary)
                }
            }

            Divider()
                .background(Color.dodoBorder.opacity(0.2))

            VStack(alignment: .leading, spacing: 8) {
                featureRow(icon: "eye.slash", text: L10n.toggleHiddenItemsVisibility)
                featureRow(icon: "menubar.dock.rectangle", text: L10n.showHideDodoNestBar)
                featureRow(icon: "command", text: L10n.customizableKeyCombinations)
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
