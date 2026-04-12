import Foundation

struct ProcessedTrain: Codable, Identifiable {
    let route: String
    let statusSummary: String
    let alerts: [TrainAlert]

    var id: String { route }

    var hasAlerts: Bool { !alerts.isEmpty }
    var isGood: Bool { statusSummary == "all good." }
}

struct TrainAlert: Codable, Identifiable {
    let id: UUID
    let type: String
    let description: String
    let createdAt: Date?
    let upcoming: Bool
    let upcomingStart: Date?
    let periodText: String?

    init(type: String, description: String, createdAt: Date?, upcoming: Bool, upcomingStart: Date?, periodText: String?) {
        self.id = UUID()
        self.type = type
        self.description = description
        self.createdAt = createdAt
        self.upcoming = upcoming
        self.upcomingStart = upcomingStart
        self.periodText = periodText
    }
}

struct TrainStatusResult: Codable {
    let trains: [ProcessedTrain]
    let cacheTime: Date

    func train(for route: String) -> ProcessedTrain? {
        trains.first { $0.route == route }
    }
}
