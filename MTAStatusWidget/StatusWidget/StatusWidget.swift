import WidgetKit
import SwiftUI

struct MTAStatusWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: MTAWidgetEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

struct MTAStatusWidget: Widget {
    let kind = "MTAStatusWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MTATimelineProvider()) { entry in
            MTAStatusWidgetView(entry: entry)
        }
        .configurationDisplayName("MTA Widget")
        .description("See the status of your subway lines at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
