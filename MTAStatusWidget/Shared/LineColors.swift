import SwiftUI

enum LineColors {
    private static let colors: [String: Color] = [
        "1": Color(hex: 0xEE352E),
        "2": Color(hex: 0xEE352E),
        "3": Color(hex: 0xEE352E),
        "4": Color(hex: 0x00933C),
        "5": Color(hex: 0x00933C),
        "6": Color(hex: 0x00933C),
        "7": Color(hex: 0xB933AD),
        "A": Color(hex: 0x0039A6),
        "C": Color(hex: 0x0039A6),
        "E": Color(hex: 0x0039A6),
        "B": Color(hex: 0xFF6319),
        "D": Color(hex: 0xFF6319),
        "F": Color(hex: 0xFF6319),
        "M": Color(hex: 0xFF6319),
        "G": Color(hex: 0x6CBE45),
        "J": Color(hex: 0x996633),
        "Z": Color(hex: 0x996633),
        "L": Color(hex: 0xA7A9AC),
        "N": Color(hex: 0xFCCC0A),
        "Q": Color(hex: 0xFCCC0A),
        "R": Color(hex: 0xFCCC0A),
        "W": Color(hex: 0xFCCC0A),
        "S": Color(hex: 0x808183),
        "GS": Color(hex: 0x808183),
        "FS": Color(hex: 0x808183),
        "H": Color(hex: 0x808183),
        "SI": Color(hex: 0x253B7E)
    ]

    static func color(for route: String) -> Color {
        colors[route] ?? Color.gray
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}
