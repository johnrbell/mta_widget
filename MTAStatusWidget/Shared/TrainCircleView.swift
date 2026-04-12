import SwiftUI

struct TrainCircleView: View {
    let route: String
    let size: CGFloat

    var body: some View {
        Circle()
            .fill(LineColors.color(for: route))
            .frame(width: size, height: size)
            .overlay(
                Text(MTAConstants.displayName(for: route))
                    .font(.system(size: size * 0.62, weight: .medium, design: .default))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.5)
            )
            .accessibilityLabel("\(MTAConstants.displayName(for: route)) train")
    }
}
