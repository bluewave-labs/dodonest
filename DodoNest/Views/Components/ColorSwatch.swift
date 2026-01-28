import SwiftUI

struct ColorSwatch: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    private let size: CGFloat = 32

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: size, height: size)

                Circle()
                    .strokeBorder(isSelected ? Color.white : Color.clear, lineWidth: 2)
                    .frame(width: size, height: size)

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}

struct AccentColorPicker: View {
    @Binding var selectedColor: AccentColorOption

    var body: some View {
        HStack(spacing: 12) {
            ForEach(AccentColorOption.allCases) { option in
                ColorSwatch(
                    color: option.color,
                    isSelected: selectedColor == option
                ) {
                    selectedColor = option
                }
                .help(option.displayName)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ColorSwatch(color: .blue, isSelected: false) {}
        ColorSwatch(color: .green, isSelected: true) {}

        AccentColorPicker(selectedColor: .constant(.green))
    }
    .padding()
    .background(Color.dodoBackground)
    .preferredColorScheme(.dark)
}
