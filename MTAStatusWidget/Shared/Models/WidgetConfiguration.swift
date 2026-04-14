import Foundation

enum WidgetTheme: String, Codable, CaseIterable, Identifiable {
    case system
    case dark
    case light
    case glass

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return "System"
        case .dark: return "Dark"
        case .light: return "Light"
        case .glass: return "Glass"
        }
    }
}

struct WidgetConfig: Codable, Equatable {
    var selectedRoutes: [String]
    var theme: WidgetTheme
    var circleSize: Double
    var fontSize: Double
    var padding: Double

    static let defaultSmall = WidgetConfig(
        selectedRoutes: [],
        theme: .system,
        circleSize: 36,
        fontSize: 11,
        padding: 4
    )

    static let defaultMedium = WidgetConfig(
        selectedRoutes: [],
        theme: .system,
        circleSize: 28,
        fontSize: 11,
        padding: 4
    )

    var trainCount: Int { selectedRoutes.count }

    mutating func addRoute(_ route: String, limit: Int) {
        guard selectedRoutes.count < limit, !selectedRoutes.contains(route) else { return }
        selectedRoutes.append(route)
    }

    mutating func removeRoute(_ route: String) {
        selectedRoutes.removeAll { $0 == route }
    }

    mutating func toggleRoute(_ route: String, limit: Int) {
        if selectedRoutes.contains(route) {
            removeRoute(route)
        } else {
            addRoute(route, limit: limit)
        }
    }

    func contains(_ route: String) -> Bool {
        selectedRoutes.contains(route)
    }
}
