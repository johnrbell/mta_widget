import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
    let entry: MTAWidgetEntry

    private var trains: [ProcessedTrain] { entry.trains }
    private var config: WidgetConfig { entry.config }
    private var theme: WidgetTheme { config.theme }
    private var focused: String? { entry.focusedRoute }

    var body: some View {
        Group {
            if let focusedRoute = focused,
               let train = trains.first(where: { $0.route == focusedRoute }) {
                focusedView(train)
            } else {
                listView
            }
        }
        .widgetBackground(theme: theme)
    }

    // MARK: - Focused view

    private func focusedView(_ train: ProcessedTrain) -> some View {
        let detail = train.alertDetail?.isEmpty == false ? train.alertDetail! : train.statusSummary

        return Button(intent: ToggleStatusIntent(route: train.route)) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    TrainCircleView(route: train.route, size: 24)
                    Text(train.statusSummary)
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundStyle(foregroundColor)
                }

                if detail != train.statusSummary {
                    Divider().opacity(0.3)
                    Text(detail)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(foregroundColor.opacity(0.8))
                        .minimumScaleFactor(0.5)
                        .lineLimit(8)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(max(config.padding, 8))
        }
        .buttonStyle(.plain)
    }

    // MARK: - List view

    private var listView: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if trains.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "tram.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(foregroundColor.opacity(0.4))
                        Text("Add trains in the app to see status here")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(foregroundColor.opacity(0.5))
                    }
                } else {
                    let rows = splitIntoRows(trains)
                    VStack(spacing: 4) {
                        ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                            HStack(spacing: 10) {
                                ForEach(row) { train in
                                    trainRow(train)
                                }
                                Spacer(minLength: 0)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Button(intent: RefreshIntent()) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(foregroundColor.opacity(0.4))
            }
            .buttonStyle(.plain)
        }
        .padding(config.padding)
    }

    private func trainRow(_ train: ProcessedTrain) -> some View {
        Button(intent: ToggleStatusIntent(route: train.route)) {
            HStack(spacing: 6) {
                TrainCircleView(route: train.route, size: config.circleSize)
                Text(train.statusSummary)
                    .font(.system(size: config.fontSize, weight: .bold))
                    .foregroundStyle(foregroundColor.opacity(0.85))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .buttonStyle(.plain)
    }

    private func splitIntoRows(_ items: [ProcessedTrain]) -> [[ProcessedTrain]] {
        if items.count <= 3 {
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
