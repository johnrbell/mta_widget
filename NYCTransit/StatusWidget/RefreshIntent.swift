import AppIntents
import WidgetKit

struct RefreshIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh NYC Transit"
    static var description: IntentDescription = "Fetches the latest subway train data"

    func perform() async throws -> some IntentResult {
        SharedDefaults.shared.focusedRoute = nil
        SharedDefaults.shared.focusedRouteExpiry = nil

        let cooldown: TimeInterval = 60
        let now = Date()
        let lastRefresh = SharedDefaults.shared.lastWidgetRefresh ?? .distantPast
        if now.timeIntervalSince(lastRefresh) >= cooldown {
            SharedDefaults.shared.lastWidgetRefresh = now
            _ = try? await TransitService.shared.fetchTrainData(bypassCache: true)
        }

        WidgetCenter.shared.reloadTimelines(ofKind: SharedDefaults.smallWidgetKind)
        WidgetCenter.shared.reloadTimelines(ofKind: SharedDefaults.mediumWidgetKind)
        return .result()
    }
}
