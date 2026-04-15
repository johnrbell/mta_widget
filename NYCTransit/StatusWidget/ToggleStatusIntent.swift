import AppIntents
import WidgetKit

struct ToggleStatusIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Train Status"
    static var description: IntentDescription = "Shows or hides the full status for a train"

    @Parameter(title: "Route")
    var route: String

    init() {
        self.route = ""
    }

    init(route: String) {
        self.route = route
    }

    func perform() async throws -> some IntentResult {
        let current = SharedDefaults.shared.focusedRoute
        if current != nil {
            SharedDefaults.shared.focusedRoute = nil
            SharedDefaults.shared.focusedRouteExpiry = nil
        } else {
            SharedDefaults.shared.focusedRoute = route
            SharedDefaults.shared.focusedRouteExpiry = Date().addingTimeInterval(10)
        }
        return .result()
    }
}
