import SwiftUI

struct GeneralSettingsView: View {
    @State private var settings = AppSettings.shared
    @State private var currentLanguage = L10n.current

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DodoNestDimensions.spacingLarge) {
                header
                startupSection

                Spacer()

                comingSoonNote
                resetSection
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
            Text(L10n.settings)
                .font(.dodoTitle)
                .foregroundColor(.dodoTextPrimary)

            Text(L10n.configureDodoNestBehavior)
                .font(.dodoBody)
                .foregroundColor(.dodoTextSecondary)
        }
    }

    // MARK: - Startup Section

    private var startupSection: some View {
        settingsCard(title: L10n.startup, icon: "power.circle.fill") {
            settingsToggleRow(
                title: L10n.launchAtLogin,
                description: L10n.automaticallyStartWhenLogin,
                isOn: $settings.launchAtLogin
            )

            Divider()
                .background(Color.dodoBorder.opacity(0.2))

            settingsToggleRow(
                title: L10n.showMenuBarIcon,
                description: L10n.displayIconInMenuBar,
                isOn: $settings.showDodoNestIcon
            )
        }
    }

    // MARK: - Coming Soon Note

    private var comingSoonNote: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundColor(.dodoTextTertiary)
                Text(L10n.moreSettingsComingSoon)
                    .font(.dodoSubheadline)
                    .foregroundColor(.dodoTextTertiary)
            }

            Text(L10n.moreSettingsDescription)
                .font(.dodoCaption)
                .foregroundColor(.dodoTextTertiary)
        }
        .padding(DodoNestDimensions.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.dodoBackgroundSecondary.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: DodoNestDimensions.borderRadiusMedium))
    }

    // MARK: - Reset Section

    private var resetSection: some View {
        HStack {
            Button(L10n.resetAllSettings) {
                settings.resetToDefaults()
            }
            .buttonStyle(.dodoDanger)

            Spacer()
        }
    }

    // MARK: - Helpers

    private func settingsToggleRow(
        title: String,
        description: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.dodoSubheadline)
                    .foregroundColor(.dodoTextPrimary)

                Text(description)
                    .font(.dodoCaption)
                    .foregroundColor(.dodoTextSecondary)
            }

            Spacer()

            Toggle("", isOn: isOn)
                .toggleStyle(.switch)
                .labelsHidden()
        }
    }

    private func settingsCard<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: DodoNestDimensions.spacingSmall) {
            HStack(spacing: DodoNestDimensions.spacingSmall) {
                Image(systemName: icon)
                    .foregroundColor(.dodoPrimary)

                Text(title)
                    .font(.dodoHeadline)
                    .foregroundColor(.dodoTextPrimary)
            }

            VStack(alignment: .leading, spacing: DodoNestDimensions.spacingSmall) {
                content()
            }
            .padding(DodoNestDimensions.cardPadding)
            .background(Color.dodoBackgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: DodoNestDimensions.borderRadiusMedium))
            .overlay(
                RoundedRectangle(cornerRadius: DodoNestDimensions.borderRadiusMedium)
                    .stroke(Color.dodoBorder.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

// MARK: - Settings Window View (for Settings scene)

struct SettingsWindowView: View {
    var body: some View {
        GeneralSettingsView()
            .frame(width: 500, height: 600)
            .background(Color.dodoBackground)
            .preferredColorScheme(.dark)
    }
}

#Preview {
    GeneralSettingsView()
        .frame(width: 700, height: 700)
        .preferredColorScheme(.dark)
}
