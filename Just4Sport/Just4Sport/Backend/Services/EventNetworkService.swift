import Foundation

class EventNetworkService {
    static let shared = EventNetworkService()
    private init() {}
    
    private let baseUrl = "http://91.227.18.176/just4sport/api"
    func fetchEvents(page: Int, size: Int = 20, completion: @escaping (Result<EventResponse, Error>) -> Void) {
        let path = "/events"
        guard var urlComponents = URLComponents(string: "\(baseUrl)\(path)") else { return }
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "size", value: "\(size)")
        ]
        
        guard let url = urlComponents.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let data = data else {
                let noDataError = NSError(domain: "Network", code: -1, userInfo: [NSLocalizedDescriptionKey: "Сервер не вернул данные"])
                DispatchQueue.main.async { completion(.failure(noDataError)) }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let eventResponse = try decoder.decode(EventResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(eventResponse))
                }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
        task.resume()
    }
}
