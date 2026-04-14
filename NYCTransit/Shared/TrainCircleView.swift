import SwiftUI

struct TrainCircleView: View {
    let route: String
    let size: CGFloat

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

    var body: some View {
        Circle()
            .fill(LineColors.color(for: route))
            .frame(width: size, height: size)
            .overlay(
                Group {
                    if isShuttle {
                        VStack(spacing: 0) {
                            Text("S")
                                .font(.system(size: size * 0.44, weight: .medium))
                            Text(shuttleSub)
                                .font(.system(size: size * 0.22, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.4)
                    } else {
                        Text(route)
                            .font(.system(size: size * 0.62, weight: .medium))
                            .foregroundStyle(.white)
                            .minimumScaleFactor(0.5)
                    }
                }
            )
            .accessibilityLabel("\(TransitConstants.displayName(for: route)) train")
    }
}
