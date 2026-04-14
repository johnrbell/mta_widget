import SwiftUI
import WidgetKit

struct TrainCircleView: View {
    let route: String
    let size: CGFloat

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

    var body: some View {
        Group {
            if renderingMode == .fullColor {
                Circle()
                    .fill(LineColors.color(for: route))
                    .frame(width: size, height: size)
                    .overlay(labelContent.foregroundStyle(.white))
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
