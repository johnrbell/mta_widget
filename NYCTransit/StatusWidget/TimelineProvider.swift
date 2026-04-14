import WidgetKit
import SwiftUI

struct TransitWidgetEntry: TimelineEntry {
    let date: Date
    let config: WidgetConfig
    let trains: [ProcessedTrain]
    let focusedRoute: String?
    let isPlaceholder: Bool
}

struct SmallTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> TransitWidgetEntry {
        TransitWidgetEntry(
            date: Date(),
            config: .defaultSmall,
            trains: placeholderTrains(),
            focusedRoute: nil,
            isPlaceholder: true
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (TransitWidgetEntry) -> Void) {
        let config = SharedDefaults.shared.smallWidgetConfig
        let cached = SharedDefaults.shared.cachedTrainStatus
        let focused = SharedDefaults.shared.focusedRoute
        let trains = selectedTrains(from: cached, config: config)
        completion(TransitWidgetEntry(date: Date(), config: config, trains: trains, focusedRoute: focused, isPlaceholder: false))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TransitWidgetEntry>) -> Void) {
        Task {
            let config = SharedDefaults.shared.smallWidgetConfig
            let focused = SharedDefaults.shared.focusedRoute
            let result = await TransitService.shared.getCachedOrFetch()
            let trains = selectedTrains(from: result, config: config)
            let entry = TransitWidgetEntry(date: Date(), config: config, trains: trains, focusedRoute: focused, isPlaceholder: false)
            let refreshDate = Date().addingTimeInterval(TransitConstants.widgetRefreshInterval)
            completion(Timeline(entries: [entry], policy: .after(refreshDate)))
        }
    }
}

struct MediumTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> TransitWidgetEntry {
        TransitWidgetEntry(
            date: Date(),
            config: .defaultMedium,
            trains: placeholderTrains(),
            focusedRoute: nil,
            isPlaceholder: true
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (TransitWidgetEntry) -> Void) {
        let config = SharedDefaults.shared.mediumWidgetConfig
        let cached = SharedDefaults.shared.cachedTrainStatus
        let focused = SharedDefaults.shared.focusedRoute
        let trains = selectedTrains(from: cached, config: config)
        completion(TransitWidgetEntry(date: Date(), config: config, trains: trains, focusedRoute: focused, isPlaceholder: false))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TransitWidgetEntry>) -> Void) {
        Task {
            let config = SharedDefaults.shared.mediumWidgetConfig
            let focused = SharedDefaults.shared.focusedRoute
            let result = await TransitService.shared.getCachedOrFetch()
            let trains = selectedTrains(from: result, config: config)
            let entry = TransitWidgetEntry(date: Date(), config: config, trains: trains, focusedRoute: focused, isPlaceholder: false)
            let refreshDate = Date().addingTimeInterval(TransitConstants.widgetRefreshInterval)
            completion(Timeline(entries: [entry], policy: .after(refreshDate)))
        }
    }
}

private func selectedTrains(from result: TrainStatusResult?, config: WidgetConfig) -> [ProcessedTrain] {
    guard let result else { return [] }
    return config.selectedRoutes.compactMap { route in
        result.train(for: route)
    }
}

private func placeholderTrains() -> [ProcessedTrain] {
    ["1", "A", "G", "L"].map {
        ProcessedTrain(route: $0, statusSummary: "all good.", alertDetail: nil)
    }
}
