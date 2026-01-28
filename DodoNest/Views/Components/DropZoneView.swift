import SwiftUI

/// A simple visual indicator line shown at insertion points during drag and drop.
struct DropIndicatorLine: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 1.5)
            .fill(Color.dodoPrimary)
            .frame(width: 3, height: 44)
    }
}

#Preview {
    HStack(spacing: 16) {
        DropIndicatorLine()
        Text("Item 1")
            .padding()
            .background(Color.gray.opacity(0.2))
        Text("Item 2")
            .padding()
            .background(Color.gray.opacity(0.2))
    }
    .padding()
    .preferredColorScheme(.dark)
}
