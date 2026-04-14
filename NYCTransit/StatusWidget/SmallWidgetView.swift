import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    let entry: TransitWidgetEntry

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
                gridView
            }
        }
        .widgetBackground(theme: theme)
    }

    private func focusedView(_ train: ProcessedTrain) -> some View {
        let detail = train.alertDetail?.isEmpty == false ? train.alertDetail! : train.statusSummary

        return Button(intent: ToggleStatusIntent(route: train.route)) {
            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    TrainCircleView(route: train.route, size: 24)
                    Text(train.statusSummary)
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(foregroundColor)
                }

                if detail != train.statusSummary {
                    Divider().opacity(0.3)
                    Text(detail)
                        .font(.system(size: 10, weight: .regular))
                        .foregroundStyle(foregroundColor.opacity(0.8))
                        .multilineTextAlignment(.leading)
                        .minimumScaleFactor(0.5)
                        .lineLimit(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(max(config.padding, 8))
        }
        .buttonStyle(.plain)
    }

    private var gridView: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if trains.isEmpty {
                    emptyState
                } else {
                    trainGrid
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Button(intent: RefreshIntent()) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(foregroundColor.opacity(0.4))
            }
            .buttonStyle(.plain)
            .padding(6)
        }
        .padding(4)
    }

    private var trainGrid: some View {
        let size = config.circleSize
        let gap = config.padding

        return VStack(spacing: gap) {
            if trains.count <= 2 {
                HStack(spacing: gap) {
                    ForEach(trains) { train in
                        trainCell(train, size: size)
                    }
                }
            } else {
                let top = Array(trains.prefix((trains.count + 1) / 2))
                let bottom = Array(trains.dropFirst((trains.count + 1) / 2))
                HStack(spacing: gap) {
                    ForEach(top) { train in
                        trainCell(train, size: size)
                    }
                }
                HStack(spacing: gap) {
                    ForEach(bottom) { train in
                        trainCell(train, size: size)
                    }
                }
            }
        }
    }

    private func trainCell(_ train: ProcessedTrain, size: CGFloat) -> some View {
        Button(intent: ToggleStatusIntent(route: train.route)) {
            VStack(spacing: 2) {
                TrainCircleView(route: train.route, size: size)
                Text(train.statusSummary)
                    .font(.system(size: statusFontSize, weight: .bold))
                    .foregroundStyle(foregroundColor.opacity(0.85))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
        }
        .buttonStyle(.plain)
    }

    private var statusFontSize: CGFloat {
        switch trains.count {
        case 1: return config.fontSize
        case 2: return config.fontSize - 1
        default: return max(config.fontSize - 3, 7)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 4) {
            Image(systemName: "tram.fill")
                .font(.system(size: 24))
                .foregroundStyle(foregroundColor.opacity(0.4))
            Text("Add trains\nin the app")
                .font(.system(size: 11, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(foregroundColor.opacity(0.5))
        }
    }

    private var foregroundColor: Color {
        switch theme {
        case .dark: return .white
        case .light: return .black
        case .system, .glass: return .primary
        }
    }
}
