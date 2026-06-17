import Foundation

class ProfileNetworkService {
    private let baseUrl = "http://91.227.18.176/just4sport/api"
    func fetchProfile(accessToken: String, completion: @escaping (Result<ProfileResponse, Error>) -> Void) {
        let urlString = "\(baseUrl)/profile"
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(NSError(domain: "NoData", code: -1))) }
                return
            }
            do {
                let decoder = JSONDecoder()
                let profile = try decoder.decode(ProfileResponse.self, from: data)
                
                DispatchQueue.main.async {
                    completion(.success(profile))
                }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
        task.resume()
    }
}
