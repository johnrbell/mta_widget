import WidgetKit
import SwiftUI

struct MTAWidgetEntry: TimelineEntry {
    let date: Date
    let config: WidgetConfig
    let trains: [ProcessedTrain]
    let expandedRoutes: Set<String>
    let isPlaceholder: Bool
}

struct MTATimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> MTAWidgetEntry {
        MTAWidgetEntry(
            date: Date(),
            config: .default,
            trains: placeholderTrains(),
            expandedRoutes: [],
            isPlaceholder: true
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (MTAWidgetEntry) -> Void) {
        let config = SharedDefaults.shared.widgetConfig
        let cached = SharedDefaults.shared.cachedTrainStatus
        let expanded = ExpandedRouteStorage.expandedRoutes

        let trains = selectedTrains(from: cached, config: config)
        completion(MTAWidgetEntry(
            date: Date(),
            config: config,
            trains: trains,
            expandedRoutes: expanded,
            isPlaceholder: false
        ))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MTAWidgetEntry>) -> Void) {
        Task {
            let config = SharedDefaults.shared.widgetConfig
            let expanded = ExpandedRouteStorage.expandedRoutes

            let result = await MTAService.shared.getCachedOrFetch()
            let trains = selectedTrains(from: result, config: config)

            let entry = MTAWidgetEntry(
                date: Date(),
                config: config,
                trains: trains,
                expandedRoutes: expanded,
                isPlaceholder: false
            )

            let refreshDate = Date().addingTimeInterval(MTAConstants.widgetRefreshInterval)
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
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
            ProcessedTrain(route: $0, statusSummary: "all good.", alerts: [])
        }
    }
}
