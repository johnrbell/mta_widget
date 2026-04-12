import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    let entry: MTAWidgetEntry

    private var trains: [ProcessedTrain] { entry.trains }
    private var theme: WidgetTheme { entry.config.theme }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            trainGrid
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Button(intent: RefreshIntent()) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(foregroundColor.opacity(0.5))
            }
            .buttonStyle(.plain)
            .padding(4)
            .accessibilityLabel("Refresh status")
        }
        .padding(8)
        .widgetBackground(theme: theme)
    }

    @ViewBuilder
    private var trainGrid: some View {
        if trains.isEmpty {
            emptyState
        } else {
            switch trains.count {
            case 1:
                singleTrain
            case 2:
                twoTrains
            case 3:
                threeTrains
            default:
                fourTrains
            }
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel("No trains selected. Open the app to add trains.")
    }

    private var singleTrain: some View {
        trainCell(trains[0], size: 52)
    }

    private var twoTrains: some View {
        HStack(spacing: 12) {
            ForEach(trains.prefix(2)) { train in
                trainCell(train, size: 44)
            }
        }
    }

    private var threeTrains: some View {
        VStack(spacing: 6) {
            HStack(spacing: 12) {
                ForEach(trains.prefix(2)) { train in
                    trainCell(train, size: 38)
                }
            }
            trainCell(trains[2], size: 38)
        }
    }

    private var fourTrains: some View {
        VStack(spacing: 6) {
            HStack(spacing: 12) {
                ForEach(trains.prefix(2)) { train in
                    trainCell(train, size: 36)
                }
            }
            HStack(spacing: 12) {
                ForEach(trains.dropFirst(2).prefix(2)) { train in
                    trainCell(train, size: 36)
                }
            }
        }
    }

    private func trainCell(_ train: ProcessedTrain, size: CGFloat) -> some View {
        let isExpanded = entry.expandedRoutes.contains(train.route)
        let showStatus = isExpanded || trains.count <= 2

        return Button(intent: ToggleStatusIntent(route: train.route)) {
            VStack(spacing: 3) {
                TrainCircleView(route: train.route, size: size)
                if showStatus {
                    Text(train.statusSummary)
                        .font(.system(size: statusFontSize, weight: .bold))
                        .foregroundStyle(foregroundColor.opacity(0.85))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .transition(.opacity.combined(with: .scale(scale: 0.8)))
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(MTAConstants.displayName(for: train.route)) train, \(train.statusSummary)")
        .accessibilityHint(showStatus ? "Tap to hide status" : "Tap to show status")
    }

    private var statusFontSize: CGFloat {
        switch trains.count {
        case 1: return 13
        case 2: return 11
        default: return 9
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
