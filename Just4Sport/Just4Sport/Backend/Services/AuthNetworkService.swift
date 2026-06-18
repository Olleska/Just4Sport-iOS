import Foundation

class AuthNetworkService {
    static let shared = AuthNetworkService()
    private init() {}
    private let baseUrl = "http://91.227.18.176/just4sport/api"
    private let sportsMapping: [String: String] = [
        "Волейбол": "VOLLEYBALL",
        "Баскетбол": "BASKETBALL",
        "Алтимат": "ULTIMATE",
        "Футбол": "SOCCER",
        "Хоккей": "HOCKEY"
    ]
    func convertSportsToBackendFormat(_ russianSports: [String]) -> [String] {
        return russianSports.compactMap { sportsMapping[$0] }
    }
    func register(requestModel: RegistrationRequest, completion: @escaping (Result<AuthResponse, Error>) -> Void) {
        guard let url = URL(string: "\(baseUrl)/auth/registration") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let jsonData = try JSONEncoder().encode(requestModel)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                let noDataError = NSError(domain: "Network", code: -1, userInfo: [NSLocalizedDescriptionKey: "Сервер не вернул данные"])
                completion(.failure(noDataError))
                return
            }
            do {
                let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                completion(.success(authResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func login(requestModel: LoginRequest, completion: @escaping (Result<AuthResponse, Error>) -> Void) {
        guard let url = URL(string: "\(baseUrl)/auth/login") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let jsonData = try JSONEncoder().encode(requestModel)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            do {
                let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                completion(.success(authResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
