import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
    let entry: MTAWidgetEntry

    private var trains: [ProcessedTrain] { entry.trains }
    private var theme: WidgetTheme { entry.config.theme }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            trainList
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Button(intent: RefreshIntent()) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(foregroundColor.opacity(0.5))
            }
            .buttonStyle(.plain)
            .padding(6)
            .accessibilityLabel("Refresh status")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .widgetBackground(theme: theme)
    }

    @ViewBuilder
    private var trainList: some View {
        if trains.isEmpty {
            HStack(spacing: 8) {
                Image(systemName: "tram.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(foregroundColor.opacity(0.4))
                Text("Add trains in the app to see status here")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(foregroundColor.opacity(0.5))
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("No trains selected. Open the app to add trains.")
        } else {
            let rows = splitIntoRows(trains)
            VStack(spacing: 6) {
                ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                    HStack(spacing: 16) {
                        ForEach(row) { train in
                            trainRow(train)
                        }
                        Spacer()
                    }
                }
            }
        }
    }

    private func trainRow(_ train: ProcessedTrain) -> some View {
        let isExpanded = entry.expandedRoutes.contains(train.route)

        return Button(intent: ToggleStatusIntent(route: train.route)) {
            HStack(spacing: 8) {
                TrainCircleView(route: train.route, size: 32)

                VStack(alignment: .leading, spacing: 1) {
                    Text(train.statusSummary)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(foregroundColor.opacity(0.85))
                        .lineLimit(1)

                    if isExpanded, let alert = train.alerts.first {
                        Text(alert.description)
                            .font(.system(size: 10))
                            .foregroundStyle(foregroundColor.opacity(0.5))
                            .lineLimit(2)
                            .transition(.opacity)
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(MTAConstants.displayName(for: train.route)) train, \(train.statusSummary)")
        .accessibilityHint("Tap to \(isExpanded ? "hide" : "show") alert details")
    }

    private func splitIntoRows(_ items: [ProcessedTrain]) -> [[ProcessedTrain]] {
        if items.count <= 2 {
            return [items]
        }
        let mid = (items.count + 1) / 2
        return [Array(items.prefix(mid)), Array(items.dropFirst(mid))]
    }

    private var foregroundColor: Color {
        switch theme {
        case .dark: return .white
        case .light: return .black
        case .system, .glass: return .primary
        }
    }
}
