import SwiftUI

// MARK: - Colors

extension Color {
    // Primary colors
    static let dodoPrimary = Color(hex: "#13715B")
    static let dodoPrimaryLight = Color(hex: "#1A8F73")
    static let dodoPrimaryDark = Color(hex: "#0E5A48")

    // Secondary colors
    static let dodoSecondary = Color(hex: "#6B7280")

    // Border and backgrounds
    static let dodoBorder = Color(hex: "#D0D5DD")
    static let dodoBackground = Color(hex: "#0F1419")
    static let dodoBackgroundSecondary = Color(hex: "#1A2027")
    static let dodoBackgroundTertiary = Color(hex: "#242D35")

    // Semantic colors
    static let dodoSuccess = Color(hex: "#10B981")
    static let dodoWarning = Color(hex: "#F59E0B")
    static let dodoDanger = Color(hex: "#EF4444")
    static let dodoInfo = Color(hex: "#3B82F6")

    // Text colors
    static let dodoTextPrimary = Color(hex: "#F9FAFB")
    static let dodoTextSecondary = Color(hex: "#9CA3AF")
    static let dodoTextTertiary = Color(hex: "#6B7280")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Dimensions

enum DodoNestDimensions {
    static let borderRadius: CGFloat = 4
    static let borderRadiusMedium: CGFloat = 8
    static let borderRadiusLarge: CGFloat = 12

    static let buttonHeight: CGFloat = 34
    static let buttonHeightSmall: CGFloat = 28
    static let buttonHeightLarge: CGFloat = 44

    static let cardPadding: CGFloat = 16
    static let cardPaddingSmall: CGFloat = 12
    static let cardPaddingLarge: CGFloat = 20

    static let spacing: CGFloat = 16
    static let spacingSmall: CGFloat = 8
    static let spacingLarge: CGFloat = 24

    static let sidebarWidth: CGFloat = 200
    static let iconSize: CGFloat = 20
    static let iconSizeLarge: CGFloat = 24

    static let menuBarItemHeight: CGFloat = 36
    static let menuBarIconSize: CGFloat = 18
}

// MARK: - Typography

extension Font {
    static let dodoTitle = Font.system(size: 24, weight: .semibold)
    static let dodoHeadline = Font.system(size: 18, weight: .semibold)
    static let dodoSubheadline = Font.system(size: 14, weight: .medium)
    static let dodoBody = Font.system(size: 14, weight: .regular)
    static let dodoCaption = Font.system(size: 12, weight: .regular)
    static let dodoCaptionSmall = Font.system(size: 11, weight: .regular)
}

// MARK: - View Modifiers

struct CardStyle: ViewModifier {
    var padding: CGFloat = DodoNestDimensions.cardPadding

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.dodoBackgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: DodoNestDimensions.borderRadiusMedium))
            .overlay(
                RoundedRectangle(cornerRadius: DodoNestDimensions.borderRadiusMedium)
                    .stroke(Color.dodoBorder.opacity(0.2), lineWidth: 1)
            )
    }
}

struct SectionCardStyle: ViewModifier {
    var isDropTarget: Bool = false

    func body(content: Content) -> some View {
        content
            .padding(DodoNestDimensions.cardPadding)
            .background(Color.dodoBackgroundTertiary.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: DodoNestDimensions.borderRadiusMedium))
            .overlay(
                RoundedRectangle(cornerRadius: DodoNestDimensions.borderRadiusMedium)
                    .stroke(isDropTarget ? Color.dodoPrimary : Color.dodoBorder.opacity(0.2), lineWidth: isDropTarget ? 2 : 1)
            )
    }
}

extension View {
    func cardStyle(padding: CGFloat = DodoNestDimensions.cardPadding) -> some View {
        modifier(CardStyle(padding: padding))
    }

    func sectionCardStyle(isDropTarget: Bool = false) -> some View {
        modifier(SectionCardStyle(isDropTarget: isDropTarget))
    }
}

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.dodoSubheadline)
            .foregroundColor(.white)
            .frame(height: DodoNestDimensions.buttonHeight)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: DodoNestDimensions.borderRadius)
                    .fill(isEnabled ? Color.dodoPrimary : Color.dodoPrimary.opacity(0.5))
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.dodoSubheadline)
            .foregroundColor(.dodoTextPrimary)
            .frame(height: DodoNestDimensions.buttonHeight)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: DodoNestDimensions.borderRadius)
                    .fill(Color.dodoBackgroundTertiary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DodoNestDimensions.borderRadius)
                    .stroke(Color.dodoBorder.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct DangerButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.dodoSubheadline)
            .foregroundColor(.white)
            .frame(height: DodoNestDimensions.buttonHeight)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: DodoNestDimensions.borderRadius)
                    .fill(isEnabled ? Color.dodoDanger : Color.dodoDanger.opacity(0.5))
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var dodoPrimary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var dodoSecondary: SecondaryButtonStyle { SecondaryButtonStyle() }
}

extension ButtonStyle where Self == DangerButtonStyle {
    static var dodoDanger: DangerButtonStyle { DangerButtonStyle() }
}
