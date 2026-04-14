import WidgetKit
import SwiftUI

struct TransitSmallWidget: Widget {
    let kind = SharedDefaults.smallWidgetKind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SmallTimelineProvider()) { entry in
            SmallWidgetView(entry: entry)
        }
        .configurationDisplayName("NYC Transit Small")
        .description("Compact subway status circles.")
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled()
    }
}

struct TransitMediumWidget: Widget {
    let kind = SharedDefaults.mediumWidgetKind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MediumTimelineProvider()) { entry in
            MediumWidgetView(entry: entry)
        }
        .configurationDisplayName("NYC Transit Medium")
        .description("Subway status with line details.")
        .supportedFamilies([.systemMedium])
        .contentMarginsDisabled()
    }
}
