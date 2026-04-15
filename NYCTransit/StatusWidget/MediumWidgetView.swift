import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
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
        let detail = train.alertDetail?.isEmpty == false ? train.alertDetail! : nil

        return VStack(spacing: 0) {
            Button(intent: ToggleStatusIntent(route: train.route)) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 10) {
                        TrainCircleView(route: train.route, size: 32, iconOverride: config.iconOverride)
                        Text(train.statusSummary)
                            .font(.system(size: 15, weight: .heavy))
                            .foregroundStyle(foregroundColor)
                        Spacer(minLength: 0)
                    }

                    if let detail {
                        Text(detail)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(foregroundColor.opacity(0.7))
                            .lineSpacing(2)
                            .multilineTextAlignment(.leading)
                            .minimumScaleFactor(0.6)
                            .lineLimit(5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(foregroundColor.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.top, 12)
                .padding(.horizontal, 12)
                .padding(.bottom, 4)
                .contentShape(Rectangle())
            }
            .buttonStyle(WidgetPressableStyle())

            Button(intent: RefreshIntent()) {
                Text("Refresh All Trains")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(foregroundColor.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 12)
                    .padding(.top, 4)
                    .contentShape(Rectangle())
            }
            .buttonStyle(WidgetPressableStyle())
        }
    }

    private var gridView: some View {
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
        .padding(4)
    }

    private var trainGrid: some View {
        let rows = gridRows(trains, columns: 4)

        return VStack(spacing: config.vSpacing) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(alignment: .top, spacing: config.hSpacing) {
                    ForEach(row) { train in
                        trainCell(train)
                    }
                }
            }
        }
    }

    private func trainCell(_ train: ProcessedTrain) -> some View {
        Button(intent: ToggleStatusIntent(route: train.route)) {
            VStack(spacing: 2) {
                TrainCircleView(route: train.route, size: config.circleSize, iconOverride: config.iconOverride)
                Text(train.formattedStatus)
                    .font(.system(size: max(config.fontSize - 2, 7), weight: .bold))
                    .foregroundStyle(foregroundColor.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(WidgetPressableStyle())
    }

    private func gridRows(_ items: [ProcessedTrain], columns: Int) -> [[ProcessedTrain]] {
        stride(from: 0, to: items.count, by: columns).map {
            Array(items[$0..<min($0 + columns, items.count)])
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
