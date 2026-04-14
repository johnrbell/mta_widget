import Foundation

enum TransitConstants {
    static let allRoutes: [String] = [
        "1", "2", "3", "4", "5", "6", "7",
        "A", "C", "E", "B", "D", "F", "M",
        "G", "J", "Z", "L", "N", "Q", "R", "W",
        "GS", "FS", "H", "SI"
    ]

    static let sortOrder: [String: Int] = [
        "1": 0, "2": 1, "3": 2, "4": 3, "5": 4, "6": 5, "7": 6,
        "A": 7, "C": 8, "E": 9, "B": 10, "D": 11, "F": 12, "M": 13,
        "G": 14, "J": 15, "Z": 16, "L": 17, "N": 18, "Q": 19, "R": 20, "W": 21,
        "GS": 22, "FS": 23, "H": 24, "SI": 25
    ]

    static let lineGroups: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7"],
        ["A", "C", "E"],
        ["B", "D", "F", "M"],
        ["G"],
        ["J", "Z"],
        ["L"],
        ["N", "Q", "R", "W"],
        ["GS", "FS", "H"],
        ["SI"]
    ]

    static let apiURL = URL(string: "https://iosmtawid.vercel.app/api/status")!
    static let fetchTimeout: TimeInterval = 10
    static let widgetRefreshInterval: TimeInterval = 15 * 60

    static let appGroupID = "group.com.johnrbell.nyctransit"

    static func displayName(for route: String) -> String {
        switch route {
        case "GS": return "S·42"
        case "FS": return "S·Fr"
        case "H":  return "S·Rk"
        default: return route
        }
    }
}
