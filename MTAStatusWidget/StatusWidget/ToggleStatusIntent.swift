import AppIntents
import WidgetKit

struct ToggleStatusIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Train Status"
    static var description: IntentDescription = "Shows or hides the status text for a train"

    @Parameter(title: "Route")
    var route: String

    init() {
        self.route = ""
    }

    init(route: String) {
        self.route = route
    }

    func perform() async throws -> some IntentResult {
        var expanded = ExpandedRouteStorage.expandedRoutes
        if expanded.contains(route) {
            expanded.remove(route)
        } else {
            expanded = [route]
        }
        ExpandedRouteStorage.expandedRoutes = expanded
        WidgetCenter.shared.reloadTimelines(ofKind: "MTAStatusWidget")
        return .result()
    }
}

enum ExpandedRouteStorage {
    private static let key = "expandedRoutes"
    private static var defaults: UserDefaults {
        UserDefaults(suiteName: MTAConstants.appGroupID) ?? .standard
    }

    static var expandedRoutes: Set<String> {
        get {
            let arr = defaults.stringArray(forKey: key) ?? []
            return Set(arr)
        }
        set {
            defaults.set(Array(newValue), forKey: key)
        }
    }
}
