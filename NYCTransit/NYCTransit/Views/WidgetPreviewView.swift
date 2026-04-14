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

        return VStack(spacing: 0) {
            if trains.count <= 2 {
                HStack(spacing: 0) {
                    ForEach(trains) { train in
                        trainCell(train, size: size)
                    }
                }
            } else {
                let top = Array(trains.prefix((trains.count + 1) / 2))
                let bottom = Array(trains.dropFirst((trains.count + 1) / 2))
                HStack(spacing: 0) {
                    ForEach(top) { train in
                        trainCell(train, size: size)
                    }
                }
                HStack(spacing: 0) {
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
        .frame(maxWidth: .infinity)
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
                    trainGrid
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

    private var trainGrid: some View {
        let gap = config.padding
        let rows = gridRows(trains, columns: 4)

        return VStack(spacing: gap) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: gap) {
                    ForEach(row) { train in
                        trainCell(train)
                    }
                }
            }
        }
    }

    private func trainCell(_ train: ProcessedTrain) -> some View {
        VStack(spacing: 2) {
            TrainCircleView(route: train.route, size: config.circleSize)
            Text(train.statusSummary)
                .font(.system(size: max(config.fontSize - 2, 7), weight: .bold))
                .foregroundStyle(foregroundColor.opacity(0.85))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .frame(maxWidth: .infinity)
    }

    private func gridRows(_ items: [ProcessedTrain], columns: Int) -> [[ProcessedTrain]] {
        stride(from: 0, to: items.count, by: columns).map {
            Array(items[$0..<min($0 + columns, items.count)])
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
