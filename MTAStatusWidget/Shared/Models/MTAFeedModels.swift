import Foundation

struct MTAFeedResponse: Decodable {
    let entity: [MTAEntity]?
}

struct MTAEntity: Decodable {
    let alert: MTAAlert?
}

struct MTAAlert: Decodable {
    let headerText: MTATranslationContainer?
    let activePeriod: [MTAActivePeriod]?
    let informedEntity: [MTAInformedEntity]?
    let mercuryAlert: MTAMercuryAlert?

    enum CodingKeys: String, CodingKey {
        case headerText = "header_text"
        case activePeriod = "active_period"
        case informedEntity = "informed_entity"
        case mercuryAlert = "transit_realtime.mercury_alert"
    }
}

struct MTATranslationContainer: Decodable {
    let translation: [MTATranslation]?
}

struct MTATranslation: Decodable {
    let language: String?
    let text: String?
}

struct MTAActivePeriod: Decodable {
    let start: TimeInterval?
    let end: TimeInterval?
}

struct MTAInformedEntity: Decodable {
    let routeId: String?

    enum CodingKeys: String, CodingKey {
        case routeId = "route_id"
    }
}

struct MTAMercuryAlert: Decodable {
    let alertType: String?
    let createdAt: TimeInterval?

    enum CodingKeys: String, CodingKey {
        case alertType = "alert_type"
        case createdAt = "created_at"
    }
}
