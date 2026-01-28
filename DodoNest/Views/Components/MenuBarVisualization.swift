import SwiftUI

struct MenuBarVisualization: View {
    let items: [MenuBarItem]
    let notchInfo: NotchInfo

    /// Scale factor for the visualization (menu bar shrunk to fit)
    private let scale: CGFloat = 0.4

    private var visualWidth: CGFloat {
        notchInfo.screenWidth * scale
    }

    private var visualHeight: CGFloat {
        notchInfo.menuBarHeight * scale * 2
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.menuBarPreview)
                .font(.dodoCaption)
                .foregroundColor(.dodoTextSecondary)

            ZStack {
                // Menu bar background
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.black.opacity(0.8))
                    .frame(width: visualWidth, height: visualHeight)

                // Notch cutout (if present)
                if notchInfo.hasNotch, let notchRect = notchInfo.notchRect {
                    notchShape(notchRect: notchRect)
                }

                // Item indicators
                itemIndicators
            }
            .frame(width: visualWidth, height: visualHeight)
        }
    }

    private func notchShape(notchRect: CGRect) -> some View {
        let notchVisualWidth = notchRect.width * scale
        let notchVisualHeight = visualHeight

        return RoundedRectangle(cornerRadius: 8)
            .fill(Color.dodoBackground)
            .frame(width: notchVisualWidth, height: notchVisualHeight + 4)
            .offset(y: -2)
    }

    private var itemIndicators: some View {
        GeometryReader { geometry in
            ForEach(items) { item in
                if let frame = item.frame {
                    let scaledX = (frame.midX / notchInfo.screenWidth) * visualWidth
                    let isHidden = AppSettings.shared.isItemHidden(item.name)

                    Circle()
                        .fill(isHidden ? Color.dodoTextTertiary : Color.dodoPrimary)
                        .frame(width: 6, height: 6)
                        .position(x: scaledX, y: visualHeight / 2)
                        .opacity(isHidden ? 0.5 : 1.0)
                }
            }
        }
    }
}

struct MenuBarVisualizationCard: View {
    @State private var items: [MenuBarItem] = []
    @State private var notchInfo: NotchInfo = .noNotch

    private var menuBarService: MenuBarService { MenuBarService.shared }
    private var notchDetector: NotchDetector { NotchDetector.shared }

    var body: some View {
        VStack(alignment: .leading, spacing: DodoNestDimensions.spacing) {
            HStack {
                Image(systemName: "display")
                    .foregroundColor(.dodoPrimary)

                Text(L10n.menuBarPreview)
                    .font(.dodoHeadline)
                    .foregroundColor(.dodoTextPrimary)

                Spacer()

                // Notch status badge
                if notchInfo.hasNotch {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.dodoSuccess)
                            .font(.system(size: 12))
                        Text(L10n.notchDetected)
                            .font(.dodoCaptionSmall)
                            .foregroundColor(.dodoSuccess)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.dodoSuccess.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "minus.circle")
                            .foregroundColor(.dodoTextTertiary)
                            .font(.system(size: 12))
                        Text(L10n.noNotchDetected)
                            .font(.dodoCaptionSmall)
                            .foregroundColor(.dodoTextTertiary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.dodoBackgroundTertiary)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }

            MenuBarVisualization(items: items, notchInfo: notchInfo)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 8)
        }
        .padding(DodoNestDimensions.cardPadding)
        .background(Color.dodoBackgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: DodoNestDimensions.borderRadiusMedium))
        .overlay(
            RoundedRectangle(cornerRadius: DodoNestDimensions.borderRadiusMedium)
                .stroke(Color.dodoBorder.opacity(0.2), lineWidth: 1)
        )
        .onAppear {
            items = menuBarService.items
            notchInfo = notchDetector.detectNotch()
        }
        .onReceive(NotificationCenter.default.publisher(for: .menuBarLayoutChanged)) { _ in
            items = menuBarService.items
        }
    }
}

#Preview {
    VStack {
        MenuBarVisualizationCard()
    }
    .padding()
    .background(Color.dodoBackground)
    .preferredColorScheme(.dark)
}
