import Foundation

actor TransitService {
    static let shared = TransitService()

    private var cachedResult: TrainStatusResult?
    private var inFlightTask: Task<TrainStatusResult, Error>?
    private let cacheTTL: TimeInterval = 300

    func fetchTrainData(bypassCache: Bool = false) async throws -> TrainStatusResult {
        if !bypassCache, let cached = cachedResult,
           Date().timeIntervalSince(cached.cacheTime) < cacheTTL {
            return cached
        }

        if let existing = inFlightTask {
            return try await existing.value
        }

        let task = Task<TrainStatusResult, Error> {
            defer { inFlightTask = nil }

            var request = URLRequest(url: TransitConstants.apiURL)
            request.timeoutInterval = TransitConstants.fetchTimeout

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                throw TransitServiceError.badResponse
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let result = try decoder.decode(TrainStatusResult.self, from: data)

            cachedResult = result
            SharedDefaults.shared.cachedTrainStatus = result

            return result
        }

        inFlightTask = task
        return try await task.value
    }

    func getCachedOrFetch() async -> TrainStatusResult {
        if let cached = SharedDefaults.shared.cachedTrainStatus {
            Task {
                _ = try? await fetchTrainData(bypassCache: true)
            }
            return cached
        }
        return (try? await fetchTrainData()) ?? TrainStatusResult(trains: [], cacheTime: Date())
    }
}

enum TransitServiceError: LocalizedError {
    case badResponse

    var errorDescription: String? {
        switch self {
        case .badResponse: return "API returned an error"
        }
    }
}
