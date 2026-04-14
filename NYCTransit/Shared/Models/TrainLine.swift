import Foundation

struct TrainLine: Identifiable, Hashable, Codable {
    let route: String

    var id: String { route }

    var displayName: String {
        TransitConstants.displayName(for: route)
    }

    var sortIndex: Int {
        TransitConstants.sortOrder[route] ?? 99
    }

    static let all: [TrainLine] = TransitConstants.allRoutes.map { TrainLine(route: $0) }
}
