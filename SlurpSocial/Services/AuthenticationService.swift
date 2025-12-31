//
//  AuthenticationService.swift
//  SlurpSocial
//
//  Created by Cali Shaw on 12/31/25.
//

import Foundation

class AuthenticationService {
    static let shared = AuthenticationService()

    private let userDefaultsKey = "currentUser"
    private let api = APIClient.shared

    private(set) var currentUser: User? {
        didSet {
            if let user = currentUser {
                saveUserToDefaults(user)
            } else {
                UserDefaults.standard.removeObject(forKey: userDefaultsKey)
                api.authToken = nil
            }
            NotificationCenter.default.post(name: .authStateChanged, object: nil)
        }
    }

    var isLoggedIn: Bool {
        return currentUser != nil && api.authToken != nil
    }

    private init() {
        loadCurrentUser()
    }

    // MARK: - Authentication Methods

    func signUp(username: String, email: String, password: String, displayName: String, completion: @escaping (Result<User, AuthError>) -> Void) {
        // Validate input
        guard !username.isEmpty, !email.isEmpty, !password.isEmpty else {
            completion(.failure(.invalidCredentials))
            return
        }

        guard isValidEmail(email) else {
            completion(.failure(.invalidEmail))
            return
        }

        guard password.count >= 6 else {
            completion(.failure(.weakPassword))
            return
        }

        let request = SignupRequest(
            username: username,
            email: email,
            password: password,
            displayName: displayName.isEmpty ? username : displayName
        )

        Task {
            do {
                let response: APIResponse<AuthResponseData> = try await api.request(
                    "/auth/signup",
                    method: .POST,
                    body: request
                )

                guard let authData = response.data else {
                    DispatchQueue.main.async {
                        completion(.failure(.unknown))
                    }
                    return
                }

                // Store token
                self.api.authToken = authData.token

                // Convert to User model
                let user = authData.user.toUser()

                DispatchQueue.main.async {
                    self.currentUser = user
                    completion(.success(user))
                }
            } catch let error as APIError {
                DispatchQueue.main.async {
                    completion(.failure(self.mapAPIError(error)))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.unknown))
                }
            }
        }
    }

    func login(email: String, password: String, completion: @escaping (Result<User, AuthError>) -> Void) {
        guard !email.isEmpty, !password.isEmpty else {
            completion(.failure(.invalidCredentials))
            return
        }

        let request = LoginRequest(email: email, password: password)

        Task {
            do {
                let response: APIResponse<AuthResponseData> = try await api.request(
                    "/auth/login",
                    method: .POST,
                    body: request
                )

                guard let authData = response.data else {
                    DispatchQueue.main.async {
                        completion(.failure(.unknown))
                    }
                    return
                }

                // Store token
                self.api.authToken = authData.token

                // Convert to User model
                let user = authData.user.toUser()

                DispatchQueue.main.async {
                    self.currentUser = user
                    completion(.success(user))
                }
            } catch let error as APIError {
                DispatchQueue.main.async {
                    completion(.failure(self.mapAPIError(error)))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.unknown))
                }
            }
        }
    }

    func logout() {
        Task {
            try? await api.requestVoid("/auth/logout", method: .POST, requiresAuth: true)
        }
        currentUser = nil
    }

    func updateProfile(displayName: String? = nil, bio: String? = nil, profileImageURL: String? = nil, completion: @escaping (Result<User, AuthError>) -> Void) {
        guard let user = currentUser else {
            completion(.failure(.notLoggedIn))
            return
        }

        let request = UpdateUserRequest(
            displayName: displayName,
            bio: bio,
            profileImageURL: profileImageURL
        )

        Task {
            do {
                let response: APIResponse<UserDTO> = try await api.request(
                    "/users/\(user.id.uuidString)",
                    method: .PUT,
                    body: request,
                    requiresAuth: true
                )

                guard let userData = response.data else {
                    DispatchQueue.main.async {
                        completion(.failure(.unknown))
                    }
                    return
                }

                let updatedUser = userData.toUser()

                DispatchQueue.main.async {
                    self.currentUser = updatedUser
                    completion(.success(updatedUser))
                }
            } catch let error as APIError {
                DispatchQueue.main.async {
                    completion(.failure(self.mapAPIError(error)))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.unknown))
                }
            }
        }
    }

    func refreshCurrentUser(completion: ((Result<User, AuthError>) -> Void)? = nil) {
        guard let user = currentUser else {
            completion?(.failure(.notLoggedIn))
            return
        }

        Task {
            do {
                let response: APIResponse<UserDTO> = try await api.request(
                    "/users/\(user.id.uuidString)",
                    requiresAuth: true
                )

                guard let userData = response.data else {
                    DispatchQueue.main.async {
                        completion?(.failure(.unknown))
                    }
                    return
                }

                let updatedUser = userData.toUser()

                DispatchQueue.main.async {
                    self.currentUser = updatedUser
                    completion?(.success(updatedUser))
                }
            } catch let error as APIError {
                DispatchQueue.main.async {
                    completion?(.failure(self.mapAPIError(error)))
                }
            } catch {
                DispatchQueue.main.async {
                    completion?(.failure(.unknown))
                }
            }
        }
    }

    func incrementRamenCount() {
        // This is now handled server-side when creating a post
        // Refresh user to get updated count
        refreshCurrentUser()
    }

    // MARK: - Private Methods

    private func loadCurrentUser() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let user = try? JSONDecoder().decode(User.self, from: data),
              api.authToken != nil else {
            return
        }
        currentUser = user
    }

    private func saveUserToDefaults(_ user: User) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    private func mapAPIError(_ error: APIError) -> AuthError {
        switch error.errorCode {
        case "invalidCredentials":
            return .invalidCredentials
        case "invalidEmail":
            return .invalidEmail
        case "weakPassword":
            return .weakPassword
        case "usernameAlreadyExists":
            return .usernameAlreadyExists
        case "emailAlreadyExists":
            return .emailAlreadyExists
        case "userNotFound":
            return .userNotFound
        case "wrongPassword":
            return .wrongPassword
        case "notLoggedIn", "unauthorized":
            return .notLoggedIn
        default:
            return .unknown
        }
    }
}

// MARK: - API Request/Response DTOs

struct SignupRequest: Encodable {
    let username: String
    let email: String
    let password: String
    let displayName: String
}

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct UpdateUserRequest: Encodable {
    let displayName: String?
    let bio: String?
    let profileImageURL: String?
}

struct AuthResponseData: Decodable {
    let user: UserDTO
    let token: String
    let tokenType: String?
}

struct UserDTO: Decodable {
    let id: UUID
    let username: String
    let email: String
    let displayName: String
    let profileImageURL: String?
    let bio: String?
    let joinDate: Date
    let ramenCount: Int

    func toUser() -> User {
        return User(
            id: id,
            username: username,
            email: email,
            displayName: displayName,
            profileImageURL: profileImageURL,
            bio: bio,
            joinDate: joinDate,
            ramenCount: ramenCount
        )
    }
}

// MARK: - Auth Errors

enum AuthError: LocalizedError {
    case invalidCredentials
    case invalidEmail
    case weakPassword
    case usernameAlreadyExists
    case emailAlreadyExists
    case userNotFound
    case wrongPassword
    case notLoggedIn
    case networkError
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Please fill in all fields"
        case .invalidEmail:
            return "Please enter a valid email address"
        case .weakPassword:
            return "Password must be at least 6 characters"
        case .usernameAlreadyExists:
            return "This username is already taken"
        case .emailAlreadyExists:
            return "An account with this email already exists"
        case .userNotFound:
            return "No account found with this email"
        case .wrongPassword:
            return "Incorrect password"
        case .notLoggedIn:
            return "You must be logged in to perform this action"
        case .networkError:
            return "Network error. Please check your connection"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let authStateChanged = Notification.Name("authStateChanged")
}
