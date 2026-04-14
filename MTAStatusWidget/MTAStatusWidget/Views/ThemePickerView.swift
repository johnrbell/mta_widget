import SwiftUI

struct ThemePickerView: View {
    @Binding var selectedTheme: WidgetTheme

    var body: some View {
        HStack(spacing: 12) {
            ForEach(WidgetTheme.allCases) { theme in
                themeCard(theme)
            }
        }
    }

    private func themeCard(_ theme: WidgetTheme) -> some View {
        let isSelected = selectedTheme == theme

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTheme = theme
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            VStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(backgroundFor(theme))
                    .frame(height: 56)
                    .overlay(
                        HStack(spacing: 4) {
                            Circle()
                                .fill(LineColors.color(for: "1"))
                                .frame(width: 16, height: 16)
                            Circle()
                                .fill(LineColors.color(for: "A"))
                                .frame(width: 16, height: 16)
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2.5)
                    )

                Text(theme.displayName)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(isSelected ? .primary : .secondary)
            }
        }
        .buttonStyle(.plain)
    }

    private func backgroundFor(_ theme: WidgetTheme) -> some ShapeStyle {
        switch theme {
        case .dark: return AnyShapeStyle(Color.black)
        case .light: return AnyShapeStyle(Color.white)
        case .glass: return AnyShapeStyle(.ultraThinMaterial)
        case .system: return AnyShapeStyle(Color(.secondarySystemBackground))
        }
    }
}
