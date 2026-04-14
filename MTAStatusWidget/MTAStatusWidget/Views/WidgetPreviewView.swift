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
                            .font(.system(size: 20))
                            .foregroundStyle(foregroundColor.opacity(0.4))
                        Text("Add trains")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(foregroundColor.opacity(0.5))
                    }
                } else {
                    trainGrid
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Image(systemName: "arrow.clockwise")
                .font(.system(size: 7, weight: .semibold))
                .foregroundStyle(foregroundColor.opacity(0.4))
                .padding(2)
        }
        .padding(config.padding)
        .background(backgroundView)
    }

    private var trainGrid: some View {
        let size = config.circleSize
        let gap: CGFloat = 4
        let showStatus = trains.count <= 2

        return VStack(spacing: gap) {
            if trains.count <= 2 {
                HStack(spacing: gap) {
                    ForEach(trains) { train in
                        previewCell(train, size: size, showStatus: showStatus)
                    }
                }
            } else {
                let top = Array(trains.prefix((trains.count + 1) / 2))
                let bottom = Array(trains.dropFirst((trains.count + 1) / 2))
                HStack(spacing: gap) {
                    ForEach(top) { train in
                        previewCell(train, size: size, showStatus: false)
                    }
                }
                HStack(spacing: gap) {
                    ForEach(bottom) { train in
                        previewCell(train, size: size, showStatus: false)
                    }
                }
            }
        }
    }

    private func previewCell(_ train: ProcessedTrain, size: CGFloat, showStatus: Bool) -> some View {
        VStack(spacing: 2) {
            TrainCircleView(route: train.route, size: size)
            if showStatus {
                Text(train.statusSummary)
                    .font(.system(size: max(config.fontSize - 2, 7), weight: .bold))
                    .foregroundStyle(foregroundColor.opacity(0.85))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
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
                    HStack(spacing: 4) {
                        Image(systemName: "tram.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(foregroundColor.opacity(0.4))
                        Text("Add trains in app")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(foregroundColor.opacity(0.5))
                    }
                } else {
                    let rows = splitRows(trains)
                    VStack(spacing: 3) {
                        ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                            HStack(spacing: 8) {
                                ForEach(row) { train in
                                    HStack(spacing: 4) {
                                        TrainCircleView(route: train.route, size: config.circleSize * 0.6)
                                        Text(train.statusSummary)
                                            .font(.system(size: max(config.fontSize - 2, 7), weight: .bold))
                                            .foregroundStyle(foregroundColor.opacity(0.85))
                                            .lineLimit(1)
                                    }
                                }
                                Spacer(minLength: 0)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Image(systemName: "arrow.clockwise")
                .font(.system(size: 6, weight: .semibold))
                .foregroundStyle(foregroundColor.opacity(0.4))
                .padding(2)
        }
        .padding(config.padding)
        .background(backgroundView)
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
