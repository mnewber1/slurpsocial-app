//
//  RamenPostService.swift
//  SlurpSocial
//
//  Created by Cali Shaw on 12/31/25.
//

import Foundation
import UIKit

class RamenPostService {
    static let shared = RamenPostService()

    private let api = APIClient.shared
    private let imageCache = NSCache<NSString, UIImage>()

    private init() {}

    // MARK: - CRUD Operations

    func createPost(_ post: RamenPost, image: UIImage?, completion: @escaping (Result<RamenPost, Error>) -> Void) {
        var imageData: String? = nil

        // Convert image to base64
        if let image = image, let jpegData = image.jpegData(compressionQuality: 0.7) {
            imageData = jpegData.base64EncodedString()
        }

        let request = CreatePostRequest(
            restaurantName: post.restaurantName,
            ramenName: post.ramenName,
            rating: post.rating,
            review: post.review,
            imageURL: post.imageURL,
            imageData: imageData,
            latitude: post.latitude,
            longitude: post.longitude,
            address: post.address,
            brothType: post.brothType?.apiValue,
            spiceLevel: post.spiceLevel?.apiValue,
            noodleTexture: post.noodleTexture?.apiValue
        )

        Task {
            do {
                let response: APIResponse<RamenPostDTO> = try await api.request(
                    "/posts",
                    method: .POST,
                    body: request,
                    requiresAuth: true
                )

                guard let postData = response.data else {
                    DispatchQueue.main.async {
                        completion(.failure(PostError.saveFailed))
                    }
                    return
                }

                let newPost = postData.toRamenPost()

                DispatchQueue.main.async {
                    // Refresh user to update ramen count
                    AuthenticationService.shared.incrementRamenCount()
                    NotificationCenter.default.post(name: .postsUpdated, object: nil)
                    completion(.success(newPost))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func getAllPosts(limit: Int = 20, offset: Int = 0, completion: @escaping (Result<[RamenPost], Error>) -> Void) {
        Task {
            do {
                let response: APIResponse<[RamenPostDTO]> = try await api.request(
                    "/posts?limit=\(limit)&offset=\(offset)"
                )

                guard let postsData = response.data else {
                    DispatchQueue.main.async {
                        completion(.success([]))
                    }
                    return
                }

                let posts = postsData.map { $0.toRamenPost() }

                DispatchQueue.main.async {
                    completion(.success(posts))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func getAllPosts() -> [RamenPost] {
        // Synchronous wrapper - returns empty and fetches async
        var result: [RamenPost] = []
        let semaphore = DispatchSemaphore(value: 0)

        getAllPosts { fetchResult in
            if case .success(let posts) = fetchResult {
                result = posts
            }
            semaphore.signal()
        }

        _ = semaphore.wait(timeout: .now() + 5)
        return result
    }

    func getPostsForUser(userId: UUID, completion: @escaping (Result<[RamenPost], Error>) -> Void) {
        Task {
            do {
                let response: APIResponse<[RamenPostDTO]> = try await api.request(
                    "/posts/user/\(userId.uuidString)"
                )

                guard let postsData = response.data else {
                    DispatchQueue.main.async {
                        completion(.success([]))
                    }
                    return
                }

                let posts = postsData.map { $0.toRamenPost() }

                DispatchQueue.main.async {
                    completion(.success(posts))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func getPostsForUser(userId: UUID) -> [RamenPost] {
        var result: [RamenPost] = []
        let semaphore = DispatchSemaphore(value: 0)

        getPostsForUser(userId: userId) { fetchResult in
            if case .success(let posts) = fetchResult {
                result = posts
            }
            semaphore.signal()
        }

        _ = semaphore.wait(timeout: .now() + 5)
        return result
    }

    func getPost(byId id: UUID, completion: @escaping (Result<RamenPost, Error>) -> Void) {
        Task {
            do {
                let response: APIResponse<RamenPostDTO> = try await api.request(
                    "/posts/\(id.uuidString)"
                )

                guard let postData = response.data else {
                    DispatchQueue.main.async {
                        completion(.failure(PostError.postNotFound))
                    }
                    return
                }

                let post = postData.toRamenPost()

                DispatchQueue.main.async {
                    completion(.success(post))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func getPost(byId id: UUID) -> RamenPost? {
        var result: RamenPost? = nil
        let semaphore = DispatchSemaphore(value: 0)

        getPost(byId: id) { fetchResult in
            if case .success(let post) = fetchResult {
                result = post
            }
            semaphore.signal()
        }

        _ = semaphore.wait(timeout: .now() + 5)
        return result
    }

    func updatePost(_ post: RamenPost, completion: @escaping (Result<RamenPost, Error>) -> Void) {
        let request = CreatePostRequest(
            restaurantName: post.restaurantName,
            ramenName: post.ramenName,
            rating: post.rating,
            review: post.review,
            imageURL: post.imageURL,
            imageData: nil,
            latitude: post.latitude,
            longitude: post.longitude,
            address: post.address,
            brothType: post.brothType?.apiValue,
            spiceLevel: post.spiceLevel?.apiValue,
            noodleTexture: post.noodleTexture?.apiValue
        )

        Task {
            do {
                let response: APIResponse<RamenPostDTO> = try await api.request(
                    "/posts/\(post.id.uuidString)",
                    method: .PUT,
                    body: request,
                    requiresAuth: true
                )

                guard let postData = response.data else {
                    DispatchQueue.main.async {
                        completion(.failure(PostError.saveFailed))
                    }
                    return
                }

                let updatedPost = postData.toRamenPost()

                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .postsUpdated, object: nil)
                    completion(.success(updatedPost))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func deletePost(_ postId: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                try await api.requestVoid(
                    "/posts/\(postId.uuidString)",
                    method: .DELETE,
                    requiresAuth: true
                )

                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .postsUpdated, object: nil)
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func likePost(_ postId: UUID, completion: ((Result<RamenPost, Error>) -> Void)? = nil) {
        Task {
            do {
                let response: APIResponse<RamenPostDTO> = try await api.request(
                    "/posts/\(postId.uuidString)/like",
                    method: .POST,
                    requiresAuth: true
                )

                guard let postData = response.data else {
                    DispatchQueue.main.async {
                        completion?(.failure(PostError.postNotFound))
                    }
                    return
                }

                let post = postData.toRamenPost()

                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .postsUpdated, object: nil)
                    completion?(.success(post))
                }
            } catch {
                DispatchQueue.main.async {
                    completion?(.failure(error))
                }
            }
        }
    }

    func likePost(_ postId: UUID) {
        likePost(postId, completion: nil)
    }

    func getNearbyPosts(latitude: Double, longitude: Double, radiusInMeters: Double = 5000, completion: @escaping (Result<[RamenPost], Error>) -> Void) {
        Task {
            do {
                let response: APIResponse<[RamenPostDTO]> = try await api.request(
                    "/posts/nearby?latitude=\(latitude)&longitude=\(longitude)&radiusInMeters=\(radiusInMeters)"
                )

                guard let postsData = response.data else {
                    DispatchQueue.main.async {
                        completion(.success([]))
                    }
                    return
                }

                let posts = postsData.map { $0.toRamenPost() }

                DispatchQueue.main.async {
                    completion(.success(posts))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func searchPosts(query: String, limit: Int = 20, offset: Int = 0, completion: @escaping (Result<[RamenPost], Error>) -> Void) {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query

        Task {
            do {
                let response: APIResponse<[RamenPostDTO]> = try await api.request(
                    "/posts/search?query=\(encodedQuery)&limit=\(limit)&offset=\(offset)"
                )

                guard let postsData = response.data else {
                    DispatchQueue.main.async {
                        completion(.success([]))
                    }
                    return
                }

                let posts = postsData.map { $0.toRamenPost() }

                DispatchQueue.main.async {
                    completion(.success(posts))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    // MARK: - Image Handling

    func loadImage(for post: RamenPost, completion: @escaping (UIImage?) -> Void) {
        // Check cache first
        if let cached = imageCache.object(forKey: post.id.uuidString as NSString) {
            completion(cached)
            return
        }

        // Check if we have local image data
        if let imageData = post.imageData, let image = UIImage(data: imageData) {
            imageCache.setObject(image, forKey: post.id.uuidString as NSString)
            completion(image)
            return
        }

        // Load from URL if available
        guard let urlString = post.imageURL, let url = URL(string: urlString) else {
            // Try loading from API
            loadImageFromAPI(postId: post.id, completion: completion)
            return
        }

        // Load from remote URL
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            self?.imageCache.setObject(image, forKey: post.id.uuidString as NSString)

            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }

    func loadImage(for post: RamenPost) -> UIImage? {
        // Check cache
        if let cached = imageCache.object(forKey: post.id.uuidString as NSString) {
            return cached
        }

        // Check local data
        if let imageData = post.imageData {
            return UIImage(data: imageData)
        }

        return nil
    }

    private func loadImageFromAPI(postId: UUID, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: "https://slurpsocial.app/api/posts/\(postId.uuidString)/image") else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            self?.imageCache.setObject(image, forKey: postId.uuidString as NSString)

            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}

// MARK: - API Request/Response DTOs

struct CreatePostRequest: Encodable {
    let restaurantName: String
    let ramenName: String
    let rating: Double
    let review: String?
    let imageURL: String?
    let imageData: String?
    let latitude: Double?
    let longitude: Double?
    let address: String?
    let brothType: String?
    let spiceLevel: String?
    let noodleTexture: String?
}

struct RamenPostDTO: Decodable {
    let id: UUID
    let userId: UUID
    let username: String?
    let userDisplayName: String?
    let userProfileImageURL: String?
    let restaurantName: String
    let ramenName: String
    let rating: Double
    let review: String?
    let imageURL: String?
    let latitude: Double?
    let longitude: Double?
    let address: String?
    let createdAt: Date
    let likes: Int
    let brothType: String?
    let spiceLevel: String?
    let noodleTexture: String?

    func toRamenPost() -> RamenPost {
        return RamenPost(
            id: id,
            userId: userId,
            restaurantName: restaurantName,
            ramenName: ramenName,
            rating: rating,
            review: review,
            imageURL: imageURL,
            imageData: nil,
            latitude: latitude,
            longitude: longitude,
            address: address,
            createdAt: createdAt,
            likes: likes,
            brothType: BrothType.fromAPIValue(brothType),
            spiceLevel: SpiceLevel.fromAPIValue(spiceLevel),
            noodleTexture: NoodleTexture.fromAPIValue(noodleTexture)
        )
    }
}

// MARK: - Enum API Mapping Extensions

extension BrothType {
    var apiValue: String {
        switch self {
        case .tonkotsu: return "TONKOTSU"
        case .shoyu: return "SHOYU"
        case .miso: return "MISO"
        case .shio: return "SHIO"
        case .tantanmen: return "TANTANMEN"
        case .tsukemen: return "TSUKEMEN"
        case .other: return "OTHER"
        }
    }

    static func fromAPIValue(_ value: String?) -> BrothType? {
        guard let value = value else { return nil }
        switch value.uppercased() {
        case "TONKOTSU": return .tonkotsu
        case "SHOYU": return .shoyu
        case "MISO": return .miso
        case "SHIO": return .shio
        case "TANTANMEN": return .tantanmen
        case "TSUKEMEN": return .tsukemen
        case "OTHER": return .other
        default: return nil
        }
    }
}

extension SpiceLevel {
    var apiValue: String {
        switch self {
        case .none: return "NONE"
        case .mild: return "MILD"
        case .medium: return "MEDIUM"
        case .hot: return "HOT"
        case .extreme: return "EXTREME"
        }
    }

    static func fromAPIValue(_ value: String?) -> SpiceLevel? {
        guard let value = value else { return nil }
        switch value.uppercased() {
        case "NONE": return .none
        case "MILD": return .mild
        case "MEDIUM": return .medium
        case "HOT": return .hot
        case "EXTREME": return .extreme
        default: return nil
        }
    }
}

extension NoodleTexture {
    var apiValue: String {
        switch self {
        case .soft: return "SOFT"
        case .medium: return "MEDIUM"
        case .firm: return "FIRM"
        case .extraFirm: return "EXTRA_FIRM"
        }
    }

    static func fromAPIValue(_ value: String?) -> NoodleTexture? {
        guard let value = value else { return nil }
        switch value.uppercased() {
        case "SOFT": return .soft
        case "MEDIUM": return .medium
        case "FIRM": return .firm
        case "EXTRA_FIRM": return .extraFirm
        default: return nil
        }
    }
}

// MARK: - Errors

enum PostError: LocalizedError {
    case postNotFound
    case unauthorized
    case saveFailed
    case networkError

    var errorDescription: String? {
        switch self {
        case .postNotFound:
            return "Post not found"
        case .unauthorized:
            return "You are not authorized to perform this action"
        case .saveFailed:
            return "Failed to save post"
        case .networkError:
            return "Network error. Please check your connection"
        }
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let postsUpdated = Notification.Name("postsUpdated")
}
