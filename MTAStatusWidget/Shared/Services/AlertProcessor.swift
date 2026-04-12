import Foundation

enum AlertProcessor {
    static func pickWorstStatus(_ types: [String]) -> String {
        guard !types.isEmpty else { return types.first ?? "" }
        var worst = types[0]
        var worstIndex = MTAConstants.severityOrder.firstIndex(of: worst) ?? -1
        for t in types {
            let idx = MTAConstants.severityOrder.firstIndex(of: t) ?? -1
            if idx > worstIndex {
                worst = t
                worstIndex = idx
            }
        }
        return worst
    }

    static func mapStatus(_ status: String) -> String {
        switch status {
        case "Planned - Suspended":
            return "planned - suspended."
        case "Planned - Part Suspended":
            return "planned - part suspended."
        case "Planned - Reroute":
            return "planned - reroute."
        case "Planned - Stops Skipped":
            return "planned - stops skipped."
        case "Planned - Express to Local":
            return "planned - express to local."
        case "Severe Delays", "Delays":
            return "trains cooked."
        case "Slow Speeds", "Reduced Service":
            return "sorta cooked."
        case "No Scheduled Service":
            return "no service."
        case "Boarding Change":
            return "boarding change."
        case "Extra Service":
            return "extra service."
        case "Station Notice":
            return "station notice."
        case "Special Schedule":
            return "special schedule."
        default:
            if status.hasPrefix("Planned") { return "planned work." }
            return status.lowercased() + "."
        }
    }

    static func formatPeriods(_ periods: [MTAActivePeriod]) -> String? {
        let sorted = periods
            .compactMap { p -> (start: TimeInterval, end: TimeInterval?)? in
                guard let s = p.start, s > 0 else { return nil }
                return (start: s, end: p.end)
            }
            .sorted { $0.start < $1.start }

        guard let first = sorted.first else { return nil }
        let last = sorted.last!

        let fmt: (TimeInterval) -> String = { ts in
            let date = Date(timeIntervalSince1970: ts)
            let dayFmt = DateFormatter()
            dayFmt.dateFormat = "EEE, MMM d"
            let timeFmt = DateFormatter()
            timeFmt.dateFormat = "h:mm a"
            return "\(dayFmt.string(from: date)) \(timeFmt.string(from: date))"
        }

        if let end = last.end {
            return "\(fmt(first.start)) to \(fmt(end))"
        }
        return "Starting \(fmt(first.start))"
    }

    static func processAlerts(_ feed: MTAFeedResponse) -> TrainStatusResult {
        let now = Date().timeIntervalSince1970
        var activeAlerts: [String: [TrainAlert]] = [:]
        var upcomingAlerts: [String: [TrainAlert]] = [:]
        let allRoutesSet = Set(MTAConstants.allRoutes)

        for entity in feed.entity ?? [] {
            guard let alert = entity.alert,
                  let mercury = alert.mercuryAlert,
                  let alertType = mercury.alertType else { continue }

            let periods = alert.activePeriod ?? []
            let isActive = periods.contains { p in
                let start = p.start ?? 0
                let end = p.end ?? .infinity
                return now >= start && now <= end
            }

            let isPlanned = alertType.hasPrefix("Planned")
            let upcomingHorizon: TimeInterval = 6 * 60 * 60
            let hasUpcoming = isPlanned && periods.contains { p in
                let start = p.start ?? 0
                return start > now && start <= now + upcomingHorizon
            }

            guard isActive || hasUpcoming else { continue }

            let headerText = alert.headerText?.translation?
                .first { $0.language == "en" }?.text ?? ""

            let createdAt = mercury.createdAt.map { Date(timeIntervalSince1970: $0) }

            var upcomingStart: Date?
            if !isActive && hasUpcoming {
                let futureStarts = periods
                    .compactMap { $0.start }
                    .filter { $0 > now && $0 <= now + upcomingHorizon }
                if let earliest = futureStarts.min() {
                    upcomingStart = Date(timeIntervalSince1970: earliest)
                }
            }

            let periodText = formatPeriods(periods)

            for ie in alert.informedEntity ?? [] {
                guard let routeId = ie.routeId, allRoutesSet.contains(routeId) else { continue }

                let alertObj = TrainAlert(
                    type: alertType,
                    description: headerText,
                    createdAt: createdAt,
                    upcoming: !isActive && hasUpcoming,
                    upcomingStart: upcomingStart,
                    periodText: periodText
                )

                if isActive {
                    activeAlerts[routeId, default: []].append(alertObj)
                } else {
                    upcomingAlerts[routeId, default: []].append(alertObj)
                }
            }
        }

        var trains: [ProcessedTrain] = []
        for route in MTAConstants.allRoutes {
            let active = activeAlerts[route] ?? []
            let upcoming = upcomingAlerts[route] ?? []
            let allAlerts = active + upcoming

            let status: String
            if !active.isEmpty {
                status = mapStatus(pickWorstStatus(active.map(\.type)))
            } else if !upcoming.isEmpty {
                status = mapStatus(pickWorstStatus(upcoming.map(\.type)))
            } else {
                status = "all good."
            }

            trains.append(ProcessedTrain(route: route, statusSummary: status, alerts: allAlerts))
        }

        trains.sort { (MTAConstants.sortOrder[$0.route] ?? 99) < (MTAConstants.sortOrder[$1.route] ?? 99) }

        return TrainStatusResult(trains: trains, cacheTime: Date())
    }
}
