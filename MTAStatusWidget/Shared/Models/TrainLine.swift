import Foundation

struct TrainLine: Identifiable, Hashable, Codable {
    let route: String

    var id: String { route }

    var displayName: String {
        MTAConstants.displayName(for: route)
    }

    var sortIndex: Int {
        MTAConstants.sortOrder[route] ?? 99
    }

    static let all: [TrainLine] = MTAConstants.allRoutes.map { TrainLine(route: $0) }
}
