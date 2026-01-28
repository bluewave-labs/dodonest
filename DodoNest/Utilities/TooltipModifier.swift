import SwiftUI

/// A view modifier that adds a tooltip to any view.
struct TooltipModifier: ViewModifier {
    let text: String

    func body(content: Content) -> some View {
        content
            .help(text)
    }
}

extension View {
    /// Adds a tooltip to the view.
    func tooltip(_ text: String) -> some View {
        modifier(TooltipModifier(text: text))
    }
}

/// A view that displays an info icon with a tooltip.
struct InfoTooltip: View {
    let text: String

    var body: some View {
        Image(systemName: "info.circle")
            .foregroundColor(.dodoTextTertiary)
            .font(.system(size: 12))
            .help(text)
    }
}

/// A view that displays a hint text below content.
struct HintText: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.dodoCaption)
            .foregroundColor(.dodoTextTertiary)
            .italic()
    }
}
