import Foundation
import WidgetKit

final class SharedDefaults {
    static let shared = SharedDefaults()

    private let defaults: UserDefaults

    private enum Keys {
        static let widgetConfig = "widgetConfig"
        static let cachedTrainStatus = "cachedTrainStatus"
    }

    private init() {
        defaults = UserDefaults(suiteName: MTAConstants.appGroupID) ?? .standard
    }

    var widgetConfig: WidgetConfig {
        get {
            guard let data = defaults.data(forKey: Keys.widgetConfig),
                  let config = try? JSONDecoder().decode(WidgetConfig.self, from: data) else {
                return .default
            }
            return config
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: Keys.widgetConfig)
            }
            WidgetCenter.shared.reloadTimelines(ofKind: "MTAStatusWidget")
        }
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
