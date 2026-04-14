import Foundation

struct ProcessedTrain: Codable, Identifiable {
    let route: String
    let statusSummary: String
    let alertDetail: String?

    var id: String { route }

    var isGood: Bool { statusSummary == "all good." }
}

struct TrainStatusResult: Codable {
    let trains: [ProcessedTrain]
    let cacheTime: Date

    func train(for route: String) -> ProcessedTrain? {
        trains.first { $0.route == route }
    }
}
