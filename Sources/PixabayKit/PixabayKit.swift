import Foundation

public enum PixabayError: LocalizedError, Equatable {
    /// The API key is missing, mistyped, regenerated or its account was deleted.
    case invalidAPIKey
    case requestFailed(statusCode: Int, message: String)

    public var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Invalid Pixabay API key."
        case let .requestFailed(statusCode, message):
            return "Pixabay request failed (\(statusCode)): \(message)"
        }
    }
}

public class PixabayKit {
    private var apiKey: String

    /// Pixabay marks responses as cacheable for 24 h; with the shared URL cache a key that was
    /// regenerated or deleted kept "working". Always ask the server (callers cache results).
    private static let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: configuration)
    }()

    public init(_ apiKey: String) {
        self.apiKey = apiKey
    }

    public func searchVideos(
        _ query: String? = nil,
        safeSearch: Bool = true,
        order: String = "popular",
        type: Video.VideoType = .all,
        editorsChoice: Bool = false,
        category: SearchCategory = .all,
        minWidth: Int = 0,
        minHeight: Int = 0,
        count: Int = 20
    ) async throws -> [Video] {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "safesearch", value: "\(safeSearch)"),
            URLQueryItem(name: "order", value: order),
            URLQueryItem(name: "video_type", value: type.rawValue),
            URLQueryItem(name: "editors_choice", value: "\(editorsChoice)"),
            URLQueryItem(name: "min_width", value: "\(minWidth)"),
            URLQueryItem(name: "min_height", value: "\(minHeight)"),
            URLQueryItem(name: "per_page", value: "\(count)")
        ]

        if category != .all {
            queryItems.append(URLQueryItem(name: "category", value: category.rawValue))
        }

        guard let url = createUrl("videos", queryItems: queryItems) else { throw URLError(.badURL) }

        let response: Response<Video> = try await fetch(url)
        return response.hits
    }

    /// Checks the key with the smallest possible request. Returns false if Pixabay rejects it;
    /// throws for other failures (e.g. no connection).
    public func validateAPIKey() async throws -> Bool {
        do {
            _ = try await searchVideos(count: 3)
            return true
        } catch PixabayError.invalidAPIKey {
            return false
        }
    }

    public func getImage(_ id: String) async throws -> Image? {
        guard let url = createUrl(queryItems: [URLQueryItem(name: "id", value: id)])
        else { throw URLError(.badURL) }

        let response: Response<Image> = try await fetch(url)
        return response.hits.first
    }

    private func fetch<Item: Codable>(_ url: URL) async throws -> Response<Item> {
        let (data, response) = try await Self.session.data(from: url)
        if let http = response as? HTTPURLResponse, !(200 ..< 300).contains(http.statusCode) {
            let message = String(decoding: data, as: UTF8.self)
            // Pixabay answers "[ERROR 400] Invalid API key" / "Invalid or missing API key".
            if [400, 401, 403].contains(http.statusCode), message.localizedCaseInsensitiveContains("api key") {
                throw PixabayError.invalidAPIKey
            }
            throw PixabayError.requestFailed(statusCode: http.statusCode, message: message)
        }
        return try JSONDecoder().decode(Response<Item>.self, from: data)
    }

    private func createUrl(_ path: String = "", queryItems: [URLQueryItem]) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "pixabay.com"
        urlComponents.path = "/api/" + path
        urlComponents.queryItems = [
            URLQueryItem(name: "key", value: apiKey)
        ] + queryItems.filter { $0.value != nil }

        return urlComponents.url
    }
}
