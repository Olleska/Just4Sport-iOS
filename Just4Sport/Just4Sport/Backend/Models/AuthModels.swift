import Foundation

struct RegistrationRequest: Encodable {
    let name: String
    let nickname: String
    let email: String
    let password: String
    let favoriteSports: [String]
}

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct AuthResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}
