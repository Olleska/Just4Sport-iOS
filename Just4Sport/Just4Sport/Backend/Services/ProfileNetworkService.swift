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
    func logout(accessToken: String, refreshToken: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseUrl)/auth/logout") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        let body: [String: String] = ["token": refreshToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }.resume()
    }
    func updateProfile(accessToken: String, body: UpdateProfileRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseUrl)/profile") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let jsonData = try JSONEncoder().encode(body)
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
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                let serverError = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Ошибка сервера: \(httpResponse.statusCode)"])
                completion(.failure(serverError))
                return
            }
            completion(.success(()))
        }.resume()
    }
    func uploadProfilePhoto(accessToken: String, imageRawData: Data, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseUrl)/profile/photo") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"avatar.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageRawData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                let serverError = NSError(
                    domain: "ServerError",
                    code: httpResponse.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "Ошибка загрузки фото: статус \(httpResponse.statusCode)"]
                )
                DispatchQueue.main.async { completion(.failure(serverError)) }
                return
            }
            DispatchQueue.main.async { completion(.success(())) }
        }
        task.resume()
    }
    func deleteProfile(accessToken: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "http://91.227.18.176/just4sport/api/profile") else {
            completion(.failure(NSError(domain: "InvalidURL", code: 400, userInfo: nil)))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                let statusError = NSError(domain: "ServerError", code: httpResponse.statusCode, userInfo: nil)
                completion(.failure(statusError))
                return
            }
            completion(.success(()))
        }
        task.resume()
    }
}
