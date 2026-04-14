import WidgetKit
import SwiftUI

struct MTASmallWidget: Widget {
    let kind = SharedDefaults.smallWidgetKind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SmallTimelineProvider()) { entry in
            SmallWidgetView(entry: entry)
        }
        .configurationDisplayName("MTA Small")
        .description("Compact subway status circles.")
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled()
    }
}

struct MTAMediumWidget: Widget {
    let kind = SharedDefaults.mediumWidgetKind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MediumTimelineProvider()) { entry in
            MediumWidgetView(entry: entry)
        }
        .configurationDisplayName("MTA Medium")
        .description("Subway status with line details.")
        .supportedFamilies([.systemMedium])
        .contentMarginsDisabled()
    }
}
