import SwiftUI
import WidgetKit

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        if hex.count == 6 {
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
        } else {
            r = 1; g = 1; b = 1
        }
        self.init(red: r, green: g, blue: b)
    }

    var hexString: String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }

}

struct TrainCircleView: View {
    let route: String
    let size: CGFloat
    var iconOverride: IconOverrideConfig? = nil

    @Environment(\.widgetRenderingMode) var renderingMode

    private var isShuttle: Bool {
        route == "GS" || route == "FS" || route == "H"
    }

    private var shuttleSub: String {
        switch route {
        case "GS": return "42"
        case "FS": return "Fkn"
        case "H":  return "Rock"
        default: return ""
        }
    }

    @ViewBuilder
    private var labelContent: some View {
        if isShuttle {
            VStack(spacing: 0) {
                Text("S")
                    .font(.system(size: size * 0.44, weight: .medium))
                Text(shuttleSub)
                    .font(.system(size: size * 0.22, weight: .semibold))
            }
            .minimumScaleFactor(0.4)
        } else {
            Text(route)
                .font(.system(size: size * 0.62, weight: .medium))
                .minimumScaleFactor(0.5)
        }
    }

    private var useOverride: Bool {
        if let ov = iconOverride, ov.enabled { return true }
        return false
    }

    var body: some View {
        Group {
            if renderingMode == .fullColor {
                if useOverride, let ov = iconOverride {
                    Circle()
                        .fill(Color(hex: ov.fillColorHex).opacity(ov.fillOpacity))
                        .frame(width: size, height: size)
                        .overlay(
                            Circle()
                                .strokeBorder(Color(hex: ov.strokeColorHex).opacity(ov.strokeOpacity), lineWidth: size * ov.strokeWidth / 100)
                        )
                        .overlay(labelContent.foregroundStyle(Color(hex: ov.letterColorHex).opacity(ov.letterOpacity)))
                } else {
                    Circle()
                        .fill(LineColors.color(for: route))
                        .frame(width: size, height: size)
                        .overlay(labelContent.foregroundStyle(.white))
                }
            } else {
                Circle()
                    .fill(.primary.opacity(0.3))
                    .frame(width: size, height: size)
                    .overlay(
                        labelContent
                            .foregroundStyle(.primary)
                            .blendMode(.destinationOut)
                    )
                    .compositingGroup()
                    .overlay(
                        Circle()
                            .strokeBorder(.primary.opacity(0.75), lineWidth: 1)
                    )
            }
        }
        .accessibilityLabel("\(TransitConstants.displayName(for: route)) train")
    }
}
