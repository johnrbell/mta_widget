import AppIntents
import WidgetKit

struct RefreshIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh NYC Transit"
    static var description: IntentDescription = "Fetches the latest subway train data"

    func perform() async throws -> some IntentResult {
        _ = try? await TransitService.shared.fetchTrainData(bypassCache: true)
        WidgetCenter.shared.reloadTimelines(ofKind: SharedDefaults.smallWidgetKind)
        WidgetCenter.shared.reloadTimelines(ofKind: SharedDefaults.mediumWidgetKind)
        return .result()
    }
}
