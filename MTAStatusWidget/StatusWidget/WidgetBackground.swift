import SwiftUI
import WidgetKit

extension View {
    @ViewBuilder
    func widgetBackground(theme: WidgetTheme) -> some View {
        switch theme {
        case .dark:
            self.containerBackground(Color.black, for: .widget)
        case .light:
            self.containerBackground(Color.white, for: .widget)
        case .glass:
            self.containerBackground(.ultraThinMaterial, for: .widget)
        case .system:
            self.containerBackground(for: .widget) {
                Color(.systemBackground)
            }
        }
    }
}
