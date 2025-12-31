//
//  APIClient.swift
//  SlurpSocial
//
//  Network layer for SlurpSocial backend API
//

import Foundation

class APIClient {
    static let shared = APIClient()

    private let baseURL = "https://slurpsocial.app/api"
    private let session: URLSession

    private let tokenKey = "authToken"

    var authToken: String? {
        get { UserDefaults.standard.string(forKey: tokenKey) }
        set {
            if let token = newValue {
                UserDefaults.standard.set(token, forKey: tokenKey)
            } else {
                UserDefaults.standard.removeObject(forKey: tokenKey)
            }
        }
    }

    private init() {
        let config = URLSessionConfiguration.default
        // Increased timeouts for Render cold starts (free tier can take 30+ seconds to wake)
        config.timeoutIntervalForRequest = 60
        config.timeoutIntervalForResource = 120
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config)
    }

    // MARK: - Generic Request Methods

    func request<T: Decodable>(_ endpoint: String,
                                method: HTTPMethod = .GET,
                                body: Encodable? = nil,
                                requiresAuth: Bool = false,
                                retryCount: Int = 1) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if requiresAuth, let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(body)
        }

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError where error.code == .timedOut && retryCount > 0 {
            // Retry on timeout (handles Render cold starts)
            print("Request timed out, retrying... (\(retryCount) retries left)")
            return try await self.request(endpoint, method: method, body: body, requiresAuth: requiresAuth, retryCount: retryCount - 1)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        // Handle error responses
        if !(200...299).contains(httpResponse.statusCode) {
            if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                throw APIError.serverError(code: errorResponse.error?.code ?? "unknown",
                                          message: errorResponse.error?.message ?? "Unknown error")
            }
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            // Try ISO8601 with fractional seconds
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter.date(from: dateString) {
                return date
            }

            // Try ISO8601 without fractional seconds
            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date")
        }

        return try decoder.decode(T.self, from: data)
    }

    func requestVoid(_ endpoint: String,
                     method: HTTPMethod = .GET,
                     body: Encodable? = nil,
                     requiresAuth: Bool = false) async throws {
        let _: APIResponse<EmptyData> = try await request(endpoint, method: method, body: body, requiresAuth: requiresAuth)
    }
}

// MARK: - HTTP Method

enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

// MARK: - API Response Wrapper

struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: T?
    let error: APIResponseError?
    let pagination: PaginationInfo?
}

struct APIResponseError: Decodable {
    let code: String
    let message: String
}

struct PaginationInfo: Decodable {
    let total: Int
    let limit: Int
    let offset: Int
    let hasMore: Bool
}

struct EmptyData: Decodable {}

// MARK: - API Error Response

struct APIErrorResponse: Decodable {
    let success: Bool
    let error: APIResponseError?
}

// MARK: - API Errors

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case serverError(code: String, message: String)
    case noData
    case decodingError
    case notAuthenticated

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .serverError(_, let message):
            return message
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .notAuthenticated:
            return "You must be logged in"
        }
    }

    var errorCode: String {
        switch self {
        case .serverError(let code, _):
            return code
        default:
            return "unknown"
        }
    }
}
