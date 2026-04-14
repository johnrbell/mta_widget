import SwiftUI

struct TrainPickerView: View {
    @Binding var config: WidgetConfig
    let trainStatus: TrainStatusResult?
    let routeLimit: Int

    private let columns = Array(repeating: GridItem(.fixed(52), spacing: 8), count: 6)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(MTAConstants.allRoutes, id: \.self) { route in
                trainCell(route)
            }
        }
    }

    private func trainCell(_ route: String) -> some View {
        let isSelected = config.contains(route)
        let isFull = config.trainCount >= routeLimit && !isSelected
        let status = trainStatus?.train(for: route)

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                config.toggleRoute(route, limit: routeLimit)
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            ZStack(alignment: .bottomTrailing) {
                TrainCircleView(route: route, size: 44)
                    .opacity(isFull ? 0.3 : 1.0)
                    .scaleEffect(isSelected ? 1.0 : 0.88)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .background(Circle().fill(Color.accentColor).frame(width: 16, height: 16))
                        .offset(x: 4, y: 4)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(isFull)
        .accessibilityLabel("\(MTAConstants.displayName(for: route)) train\(isSelected ? ", selected" : "")")
        .accessibilityValue(status?.statusSummary ?? "")
    }
}
