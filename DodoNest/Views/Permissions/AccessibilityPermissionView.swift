import SwiftUI

/// A view that guides the user through granting Accessibility permissions.
struct AccessibilityPermissionView: View {
    @ObservedObject private var accessibilityManager = AccessibilityManager.shared
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "hand.raised.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.dodoWarning)

                Text("Accessibility permission required")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.dodoTextPrimary)

                Text("DodoNest needs Accessibility access to move and arrange your menu bar items.")
                    .font(.dodoBody)
                    .foregroundColor(.dodoTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                // Important note about restart
                VStack(spacing: 6) {
                    Text("If already enabled but not working:")
                        .font(.dodoCaption)
                        .fontWeight(.medium)
                        .foregroundColor(.dodoTextSecondary)

                    Text("1. Remove DodoNest from Accessibility list\n2. Click \"Show in Finder\" below, then drag the app to Accessibility\n3. Restart the app")
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
                        Text("Permission granted!")
                            .font(.dodoSubheadline)
                            .foregroundColor(.dodoSuccess)
                    }
                    .padding(.bottom, 8)

                    Button("Continue") {
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
                            Text("Open System Settings")
                        }
                    }
                    .buttonStyle(.dodoPrimary)

                    HStack(spacing: 12) {
                        Button("Show in Finder") {
                            showAppInFinder()
                        }
                        .buttonStyle(.dodoSecondary)

                        Button("Restart DodoNest") {
                            restartApp()
                        }
                        .buttonStyle(.dodoSecondary)
                    }

                    Button("I'll do this later") {
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

    var body: some View {
        if !accessibilityManager.isAccessibilityGranted {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.dodoWarning)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Accessibility permission required")
                        .font(.dodoSubheadline)
                        .foregroundColor(.dodoTextPrimary)

                    Text("Enable in System Settings, then restart app")
                        .font(.dodoCaption)
                        .foregroundColor(.dodoTextSecondary)
                }

                Spacer()

                Button("Grant access") {
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
        }
    }
}

#Preview {
    AccessibilityPermissionView(isPresented: .constant(true))
        .preferredColorScheme(.dark)
}
