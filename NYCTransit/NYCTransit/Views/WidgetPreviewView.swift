import SwiftUI
import WidgetKit

struct WidgetPreviewView: View {
    let config: WidgetConfig
    let trainStatus: TrainStatusResult?
    let family: WidgetKit.WidgetFamily

    private var selectedTrains: [ProcessedTrain] {
        config.selectedRoutes.compactMap { route in
            trainStatus?.train(for: route)
        }
    }

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                SmallPreview(config: config, trains: selectedTrains)
            case .systemMedium:
                MediumPreview(config: config, trains: selectedTrains)
            default:
                SmallPreview(config: config, trains: selectedTrains)
            }
        }
    }
}

private struct SmallPreview: View {
    let config: WidgetConfig
    let trains: [ProcessedTrain]

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if trains.isEmpty {
                    VStack(spacing: 4) {
                        Image(systemName: "tram.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(foregroundColor.opacity(0.4))
                        Text("Add trains\nin the app")
                            .font(.system(size: 11, weight: .medium))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(foregroundColor.opacity(0.5))
                    }
                } else {
                    trainGrid
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Image(systemName: "arrow.clockwise")
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(foregroundColor.opacity(0.4))
                .padding(6)
        }
        .padding(4)
        .background(backgroundView)
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
        VStack(spacing: 2) {
            TrainCircleView(route: train.route, size: size)
            Text(train.statusSummary)
                .font(.system(size: statusFontSize, weight: .bold))
                .foregroundStyle(foregroundColor.opacity(0.85))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
    }

    private var statusFontSize: CGFloat {
        switch trains.count {
        case 1: return config.fontSize
        case 2: return config.fontSize - 1
        default: return max(config.fontSize - 3, 7)
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch config.theme {
        case .dark: Color.black
        case .light: Color.white
        case .glass: Color(.systemBackground).opacity(0.6)
        case .system: Color(.secondarySystemBackground)
        }
    }

    private var foregroundColor: Color {
        switch config.theme {
        case .dark: return .white
        case .light: return .black
        case .system, .glass: return .primary
        }
    }
}

private struct MediumPreview: View {
    let config: WidgetConfig
    let trains: [ProcessedTrain]

    var body: some View {
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
                    let rows = splitRows(trains)
                    VStack(spacing: config.padding) {
                        ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                            HStack(spacing: config.padding + 6) {
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

            Image(systemName: "arrow.clockwise")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(foregroundColor.opacity(0.4))
                .padding(6)
        }
        .padding(4)
        .background(backgroundView)
    }

    private func trainRow(_ train: ProcessedTrain) -> some View {
        HStack(spacing: 6) {
            TrainCircleView(route: train.route, size: config.circleSize)
            Text(train.statusSummary)
                .font(.system(size: config.fontSize, weight: .bold))
                .foregroundStyle(foregroundColor.opacity(0.85))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    private func splitRows(_ items: [ProcessedTrain]) -> [[ProcessedTrain]] {
        if items.count <= 3 { return [items] }
        let mid = (items.count + 1) / 2
        return [Array(items.prefix(mid)), Array(items.dropFirst(mid))]
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch config.theme {
        case .dark: Color.black
        case .light: Color.white
        case .glass: Color(.systemBackground).opacity(0.6)
        case .system: Color(.secondarySystemBackground)
        }
    }

    private var foregroundColor: Color {
        switch config.theme {
        case .dark: return .white
        case .light: return .black
        case .system, .glass: return .primary
        }
    }
}
