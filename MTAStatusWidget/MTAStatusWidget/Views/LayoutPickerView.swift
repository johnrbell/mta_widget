import SwiftUI

struct LayoutPickerView: View {
    @Binding var selectedLayout: WidgetLayout
    let trainCount: Int

    var body: some View {
        HStack(spacing: 12) {
            ForEach(WidgetLayout.allCases) { layout in
                layoutCard(layout)
            }
        }
    }

    private func layoutCard(_ layout: WidgetLayout) -> some View {
        let isSelected = selectedLayout == layout
        let count = max(trainCount, 1)

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedLayout = layout
                SharedDefaults.shared.widgetConfig.layout = layout
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            VStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.tertiarySystemBackground))
                    .frame(height: 56)
                    .overlay(
                        layoutPreview(layout, count: count)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2.5)
                    )

                Text(layout.displayName)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(isSelected ? .primary : .secondary)
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func layoutPreview(_ layout: WidgetLayout, count: Int) -> some View {
        let dotSize: CGFloat = 10
        switch layout {
        case .grid:
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    ForEach(0..<min(count, 2), id: \.self) { _ in dot(dotSize) }
                }
                if count > 2 {
                    HStack(spacing: 4) {
                        ForEach(0..<(count - 2), id: \.self) { _ in dot(dotSize) }
                    }
                }
            }
        case .row:
            HStack(spacing: 4) {
                ForEach(0..<count, id: \.self) { _ in dot(dotSize) }
            }
        case .column:
            VStack(spacing: 3) {
                ForEach(0..<count, id: \.self) { _ in dot(dotSize) }
            }
        }
    }

    private func dot(_ size: CGFloat) -> some View {
        Circle()
            .fill(Color.accentColor.opacity(0.6))
            .frame(width: size, height: size)
    }
}
