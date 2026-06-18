import Foundation

class TokenManager {
    static let shared = TokenManager()
    private init() {}
    
    private let accessTokenKey = "UserDefaultsAccessTokenKey"
    private let refreshTokenKey = "UserDefaultsRefreshTokenKey"
    private let userIdKey = "AppUserId"
    
    func saveTokens(accessToken: String, refreshToken: String) {
        UserDefaults.standard.set(accessToken, forKey: accessTokenKey)
        UserDefaults.standard.set(refreshToken, forKey: refreshTokenKey)
        print("""
              Токены успешно сохранены!
              Access Token: \(accessToken)
              Refresh Token: \(refreshToken)
        """)
    }
    
    func getAccessToken() -> String? {
        return UserDefaults.standard.string(forKey: accessTokenKey)
    }
    
    func clearTokens() {
        UserDefaults.standard.removeObject(forKey: accessTokenKey)
        UserDefaults.standard.removeObject(forKey: refreshTokenKey)
    }
    
    func saveSession(token: String, userId: String) {
        UserDefaults.standard.set(token, forKey: accessTokenKey)
        UserDefaults.standard.set(userId, forKey: userIdKey)
    }
        
    func getUserId() -> String? {
        return UserDefaults.standard.string(forKey: userIdKey)
    }
}
