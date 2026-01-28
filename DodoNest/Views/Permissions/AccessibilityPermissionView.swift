import SwiftUI

/// A view that guides the user through granting Accessibility permissions.
struct AccessibilityPermissionView: View {
    @ObservedObject private var accessibilityManager = AccessibilityManager.shared
    @Binding var isPresented: Bool
    @State private var currentLanguage = L10n.current

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "hand.raised.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.dodoWarning)

                Text(L10n.accessibilityPermissionRequired)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.dodoTextPrimary)

                Text(L10n.accessibilityDescription)
                    .font(.dodoBody)
                    .foregroundColor(.dodoTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                // Important note about restart
                VStack(spacing: 6) {
                    Text(L10n.ifAlreadyEnabledNotWorking)
                        .font(.dodoCaption)
                        .fontWeight(.medium)
                        .foregroundColor(.dodoTextSecondary)

                    Text(L10n.accessibilitySteps)
                        .font(.dodoCaption)
                        .foregroundColor(.dodoTextTertiary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 8)
                .padding(.horizontal, 24)
            }
            .padding(.top, 32)

            Spacer()

            // Actions
            VStack(spacing: 12) {
                if accessibilityManager.isAccessibilityGranted {
                    // Permission granted
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.dodoSuccess)
                        Text(L10n.permissionGranted)
                            .font(.dodoSubheadline)
                            .foregroundColor(.dodoSuccess)
                    }
                    .padding(.bottom, 8)

                    Button(L10n.continueButton) {
                        isPresented = false
                    }
                    .buttonStyle(.dodoPrimary)
                } else {
                    // Permission not granted
                    Button {
                        accessibilityManager.openAccessibilitySettings()
                    } label: {
                        HStack {
                            Image(systemName: "gear")
                            Text(L10n.openSystemSettings)
                        }
                    }
                    .buttonStyle(.dodoPrimary)

                    HStack(spacing: 12) {
                        Button(L10n.showInFinder) {
                            showAppInFinder()
                        }
                        .buttonStyle(.dodoSecondary)

                        Button(L10n.restartApp) {
                            restartApp()
                        }
                        .buttonStyle(.dodoSecondary)
                    }

                    Button(L10n.illDoThisLater) {
                        isPresented = false
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.dodoTextTertiary)
                    .font(.dodoCaption)
                }
            }
            .padding(.bottom, 24)
        }
        .frame(width: 420, height: 380)
        .background(Color.dodoBackground)
        .onReceive(NotificationCenter.default.publisher(for: .languageChanged)) { _ in
            currentLanguage = L10n.current
        }
    }

    private func restartApp() {
        guard let bundlePath = Bundle.main.bundlePath as String? else { return }

        // Use a shell script to wait for this process to exit, then relaunch
        let script = """
            sleep 0.5
            open "\(bundlePath)"
            """

        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", script]
        try? task.run()

        // Terminate immediately
        NSApp.terminate(nil)
    }

    private func showAppInFinder() {
        let bundleURL = Bundle.main.bundleURL
        NSWorkspace.shared.selectFile(bundleURL.path, inFileViewerRootedAtPath: bundleURL.deletingLastPathComponent().path)
    }
}

/// A banner that shows when accessibility permission is not granted.
struct AccessibilityBanner: View {
    @ObservedObject private var accessibilityManager = AccessibilityManager.shared
    @State private var showPermissionSheet = false
    @State private var currentLanguage = L10n.current

    var body: some View {
        if !accessibilityManager.isAccessibilityGranted {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.dodoWarning)

                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.accessibilityPermissionRequired)
                        .font(.dodoSubheadline)
                        .foregroundColor(.dodoTextPrimary)

                    Text(L10n.enableThenRestart)
                        .font(.dodoCaption)
                        .foregroundColor(.dodoTextSecondary)
                }

                Spacer()

                Button(L10n.grantAccess) {
                    showPermissionSheet = true
                }
                .buttonStyle(.dodoPrimary)
            }
            .padding(DodoNestDimensions.cardPadding)
            .background(Color.dodoWarning.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: DodoNestDimensions.borderRadiusMedium))
            .overlay(
                RoundedRectangle(cornerRadius: DodoNestDimensions.borderRadiusMedium)
                    .stroke(Color.dodoWarning.opacity(0.3), lineWidth: 1)
            )
            .sheet(isPresented: $showPermissionSheet) {
                AccessibilityPermissionView(isPresented: $showPermissionSheet)
            }
            .onReceive(NotificationCenter.default.publisher(for: .languageChanged)) { _ in
                currentLanguage = L10n.current
            }
        }
    }
}

#Preview {
    AccessibilityPermissionView(isPresented: .constant(true))
        .preferredColorScheme(.dark)
}
