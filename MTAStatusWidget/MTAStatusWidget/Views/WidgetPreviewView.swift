import SwiftUI
import WidgetKit

struct WidgetPreviewView: View {
    let config: WidgetConfig
    let trainStatus: TrainStatusResult?
    let family: WidgetFamily

    private var selectedTrains: [ProcessedTrain] {
        config.selectedRoutes.compactMap { route in
            trainStatus?.train(for: route)
        }
    }

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                SmallWidgetPreview(
                    config: config,
                    trains: selectedTrains
                )
            case .systemMedium:
                MediumWidgetPreview(
                    config: config,
                    trains: selectedTrains
                )
            default:
                SmallWidgetPreview(
                    config: config,
                    trains: selectedTrains
                )
            }
        }
    }
}

private struct SmallWidgetPreview: View {
    let config: WidgetConfig
    let trains: [ProcessedTrain]

    var body: some View {
        ZStack(alignment: .topTrailing) {
            trainGrid
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Image(systemName: "arrow.clockwise")
                .font(.system(size: 8, weight: .semibold))
                .foregroundStyle(foregroundColor.opacity(0.5))
                .padding(6)
        }
        .padding(8)
        .background(backgroundView)
    }

    @ViewBuilder
    private var trainGrid: some View {
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
            let size: CGFloat = trains.count <= 2 ? 40 : 32
            VStack(spacing: 4) {
                HStack(spacing: 8) {
                    ForEach(trains.prefix(2)) { train in
                        previewCell(train, size: size)
                    }
                }
                if trains.count > 2 {
                    HStack(spacing: 8) {
                        ForEach(trains.dropFirst(2).prefix(2)) { train in
                            previewCell(train, size: size)
                        }
                    }
                }
            }
        }
    }

    private func previewCell(_ train: ProcessedTrain, size: CGFloat) -> some View {
        VStack(spacing: 2) {
            TrainCircleView(route: train.route, size: size)
            if trains.count <= 2 {
                Text(train.statusSummary)
                    .font(.system(size: 8, weight: .bold))
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

private struct MediumWidgetPreview: View {
    let config: WidgetConfig
    let trains: [ProcessedTrain]

    var body: some View {
        ZStack(alignment: .topTrailing) {
            trainContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Image(systemName: "arrow.clockwise")
                .font(.system(size: 7, weight: .semibold))
                .foregroundStyle(foregroundColor.opacity(0.5))
                .padding(5)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(backgroundView)
    }

    @ViewBuilder
    private var trainContent: some View {
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
            VStack(spacing: 3) {
                ForEach(trains) { train in
                    HStack(spacing: 5) {
                        TrainCircleView(route: train.route, size: 14)
                        Text(train.statusSummary)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(foregroundColor.opacity(0.85))
                            .lineLimit(1)
                        Spacer()
                    }
                }
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
