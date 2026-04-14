import AppIntents
import WidgetKit

struct RefreshIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh MTA Widget"
    static var description: IntentDescription = "Fetches the latest MTA train data"

    func perform() async throws -> some IntentResult {
        _ = try? await MTAService.shared.fetchTrainData(bypassCache: true)
        WidgetCenter.shared.reloadTimelines(ofKind: SharedDefaults.smallWidgetKind)
        WidgetCenter.shared.reloadTimelines(ofKind: SharedDefaults.mediumWidgetKind)
        return .result()
    }
}
