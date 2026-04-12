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

enum WidgetLayout: String, Codable, CaseIterable, Identifiable {
    case grid
    case row
    case column

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .grid: return "Grid"
        case .row: return "Row"
        case .column: return "Column"
        }
    }
}

struct WidgetConfig: Codable, Equatable {
    var selectedRoutes: [String]
    var theme: WidgetTheme
    var layout: WidgetLayout

    static let `default` = WidgetConfig(
        selectedRoutes: [],
        theme: .system,
        layout: .grid
    )

    var trainCount: Int { selectedRoutes.count }

    mutating func addRoute(_ route: String) {
        guard selectedRoutes.count < 4, !selectedRoutes.contains(route) else { return }
        selectedRoutes.append(route)
    }

    mutating func removeRoute(_ route: String) {
        selectedRoutes.removeAll { $0 == route }
    }

    mutating func toggleRoute(_ route: String) {
        if selectedRoutes.contains(route) {
            removeRoute(route)
        } else {
            addRoute(route)
        }
    }

    func contains(_ route: String) -> Bool {
        selectedRoutes.contains(route)
    }
}
