import Foundation
import WidgetKit

final class SharedDefaults {
    static let shared = SharedDefaults()

    private let defaults: UserDefaults

    static let smallWidgetKind = "TransitSmallWidget"
    static let mediumWidgetKind = "TransitMediumWidget"

    private enum Keys {
        static let legacyWidgetConfig = "widgetConfig"
        static let smallWidgetConfig = "smallWidgetConfig"
        static let mediumWidgetConfig = "mediumWidgetConfig"
        static let cachedTrainStatus = "cachedTrainStatus"
        static let focusedRoute = "focusedRoute"
        static let focusedRouteExpiry = "focusedRouteExpiry"
        static let lastWidgetRefresh = "lastWidgetRefresh"
    }

    private init() {
        defaults = UserDefaults(suiteName: TransitConstants.appGroupID) ?? .standard
        migrateIfNeeded()
    }

    private func migrateIfNeeded() {
        guard let legacyData = defaults.data(forKey: Keys.legacyWidgetConfig) else { return }

        if defaults.data(forKey: Keys.smallWidgetConfig) == nil {
            defaults.set(legacyData, forKey: Keys.smallWidgetConfig)
        }
        if defaults.data(forKey: Keys.mediumWidgetConfig) == nil {
            defaults.set(legacyData, forKey: Keys.mediumWidgetConfig)
        }
        defaults.removeObject(forKey: Keys.legacyWidgetConfig)
    }

    var smallWidgetConfig: WidgetConfig {
        get {
            guard let data = defaults.data(forKey: Keys.smallWidgetConfig),
                  let config = try? JSONDecoder().decode(WidgetConfig.self, from: data) else {
                return .defaultSmall
            }
            return config
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: Keys.smallWidgetConfig)
            }
            WidgetCenter.shared.reloadTimelines(ofKind: Self.smallWidgetKind)
        }
    }

    var mediumWidgetConfig: WidgetConfig {
        get {
            guard let data = defaults.data(forKey: Keys.mediumWidgetConfig),
                  let config = try? JSONDecoder().decode(WidgetConfig.self, from: data) else {
                return .defaultMedium
            }
            return config
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: Keys.mediumWidgetConfig)
            }
            WidgetCenter.shared.reloadTimelines(ofKind: Self.mediumWidgetKind)
        }
    }

    var focusedRoute: String? {
        get { defaults.string(forKey: Keys.focusedRoute) }
        set {
            defaults.set(newValue, forKey: Keys.focusedRoute)
            WidgetCenter.shared.reloadTimelines(ofKind: Self.smallWidgetKind)
            WidgetCenter.shared.reloadTimelines(ofKind: Self.mediumWidgetKind)
        }
    }

    var focusedRouteExpiry: Date? {
        get { defaults.object(forKey: Keys.focusedRouteExpiry) as? Date }
        set { defaults.set(newValue, forKey: Keys.focusedRouteExpiry) }
    }

    var lastWidgetRefresh: Date? {
        get { defaults.object(forKey: Keys.lastWidgetRefresh) as? Date }
        set { defaults.set(newValue, forKey: Keys.lastWidgetRefresh) }
    }

    var cachedTrainStatus: TrainStatusResult? {
        get {
            guard let data = defaults.data(forKey: Keys.cachedTrainStatus) else { return nil }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try? decoder.decode(TrainStatusResult.self, from: data)
        }
        set {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            if let data = try? encoder.encode(newValue) {
                defaults.set(data, forKey: Keys.cachedTrainStatus)
            }
        }
    }
}
