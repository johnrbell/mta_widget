import SwiftUI

struct TrainPickerView: View {
    @Binding var config: WidgetConfig
    let trainStatus: TrainStatusResult?

    var body: some View {
        VStack(spacing: 10) {
            ForEach(MTAConstants.lineGroups, id: \.self) { group in
                HStack(spacing: 8) {
                    ForEach(group, id: \.self) { route in
                        trainButton(route)
                    }
                    Spacer()
                }
            }
        }
    }

    private func trainButton(_ route: String) -> some View {
        let isSelected = config.contains(route)
        let status = trainStatus?.train(for: route)
        let isFull = config.trainCount >= 4 && !isSelected
        let displayName = MTAConstants.displayName(for: route)

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                config.toggleRoute(route)
                SharedDefaults.shared.widgetConfig = config
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    TrainCircleView(route: route, size: 44)
                        .opacity(isFull ? 0.35 : 1.0)
                        .scaleEffect(isSelected ? 1.0 : 0.92)

                    if isSelected {
                        Circle()
                            .stroke(Color.accentColor, lineWidth: 3)
                            .frame(width: 50, height: 50)

                        if let order = config.selectedRoutes.firstIndex(of: route) {
                            Text("\(order + 1)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(3)
                                .background(Color.accentColor)
                                .clipShape(Circle())
                                .offset(x: 18, y: -18)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                }

                if let status, !status.isGood {
                    Text(status.statusSummary)
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .frame(width: 54)
                } else {
                    Color.clear.frame(height: 10)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(isFull)
        .accessibilityLabel("\(displayName) train\(isSelected ? ", selected" : "")")
        .accessibilityHint(
            isFull ? "Maximum 4 trains already selected" :
            isSelected ? "Double tap to remove" : "Double tap to add"
        )
        .accessibilityValue(status?.statusSummary ?? "")
    }
}
