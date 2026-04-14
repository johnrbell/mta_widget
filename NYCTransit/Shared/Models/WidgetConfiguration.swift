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
    var hSpacing: Double
    var vSpacing: Double

    var padding: Double {
        get { hSpacing }
        set { hSpacing = newValue; vSpacing = newValue }
    }

    enum CodingKeys: String, CodingKey {
        case selectedRoutes, theme, circleSize, fontSize, hSpacing, vSpacing, padding
    }

    init(selectedRoutes: [String], theme: WidgetTheme, circleSize: Double, fontSize: Double, hSpacing: Double, vSpacing: Double) {
        self.selectedRoutes = selectedRoutes
        self.theme = theme
        self.circleSize = circleSize
        self.fontSize = fontSize
        self.hSpacing = hSpacing
        self.vSpacing = vSpacing
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        selectedRoutes = try container.decode([String].self, forKey: .selectedRoutes)
        theme = try container.decode(WidgetTheme.self, forKey: .theme)
        circleSize = try container.decode(Double.self, forKey: .circleSize)
        fontSize = try container.decode(Double.self, forKey: .fontSize)
        if let h = try? container.decode(Double.self, forKey: .hSpacing),
           let v = try? container.decode(Double.self, forKey: .vSpacing) {
            hSpacing = h
            vSpacing = v
        } else {
            let legacy = (try? container.decode(Double.self, forKey: .padding)) ?? 4
            hSpacing = legacy
            vSpacing = legacy
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(selectedRoutes, forKey: .selectedRoutes)
        try container.encode(theme, forKey: .theme)
        try container.encode(circleSize, forKey: .circleSize)
        try container.encode(fontSize, forKey: .fontSize)
        try container.encode(hSpacing, forKey: .hSpacing)
        try container.encode(vSpacing, forKey: .vSpacing)
    }

    static let defaultSmall = WidgetConfig(
        selectedRoutes: [],
        theme: .system,
        circleSize: 36,
        fontSize: 11,
        hSpacing: 0,
        vSpacing: 0
    )

    static let defaultMedium = WidgetConfig(
        selectedRoutes: [],
        theme: .system,
        circleSize: 28,
        fontSize: 11,
        hSpacing: 0,
        vSpacing: 0
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
