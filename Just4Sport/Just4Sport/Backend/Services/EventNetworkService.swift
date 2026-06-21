import Foundation

class EventNetworkService {
    static let shared = EventNetworkService()
    private init() {}
    
    private let baseUrl = "http://91.227.18.176/just4sport/api"
    func fetchEvents(page: Int, size: Int = 20, filters: EventFilterParameters? = nil, completion: @escaping (Result<EventResponse, Error>) -> Void) {
        let path = "/events"
        guard var urlComponents = URLComponents(string: "\(baseUrl)\(path)") else { return }
        var queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "size", value: "\(size)")
        ]
        if let filters = filters {
            if let name = filters.name, !name.isEmpty {
                queryItems.append(URLQueryItem(name: "name", value: name))
            }
            if let sport = filters.sport {
                queryItems.append(URLQueryItem(name: "sport", value: sport))
            }
            if let eventType = filters.eventType {
                queryItems.append(URLQueryItem(name: "eventType", value: eventType))
            }
            if let skillLevel = filters.skillLevel {
                queryItems.append(URLQueryItem(name: "skillLevel", value: skillLevel))
            }
            if let status = filters.status {
                queryItems.append(URLQueryItem(name: "status", value: status))
            }
            if let sortField = filters.sortField {
                queryItems.append(URLQueryItem(name: "sortField", value: sortField))
            }
            if let sortDirection = filters.sortDirection {
                queryItems.append(URLQueryItem(name: "order", value: sortDirection))
            }
            if let costStart = filters.costStart {
                queryItems.append(URLQueryItem(name: "costStart", value: "\(costStart)"))
            }
            if let costEnd = filters.costEnd {
                queryItems.append(URLQueryItem(name: "costEnd", value: "\(costEnd)"))
            }
            if let dateStart = filters.dateStart {
                queryItems.append(URLQueryItem(name: "dateStart", value: dateStart))
            }
            if let dateEnd = filters.dateEnd {
                queryItems.append(URLQueryItem(name: "dateEnd", value: dateEnd))
            }
        }
        urlComponents.queryItems = queryItems
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
    func createEvent(model: EventCreateModel, photoData: Data? = nil, completion: @escaping (Result<Void, Error>) -> Void) {
        let path = "/events"
        guard let url = URL(string: "\(baseUrl)\(path)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = TokenManager.shared.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        var body = Data()
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(model)
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"event\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: application/json\r\n\r\n".data(using: .utf8)!)
            body.append(jsonData)
            body.append("\r\n".data(using: .utf8)!)
            if let photo = photoData {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"file\"; filename=\"event_image.jpg\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                body.append(photo)
                body.append("\r\n".data(using: .utf8)!)
            }
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
            request.httpBody = body
            
        } catch {
            DispatchQueue.main.async { completion(.failure(error)) }
            return
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    DispatchQueue.main.async { completion(.success(())) }
                } else {
                    let serverMessage = data != nil ? (String(data: data!, encoding: .utf8) ?? "") : ""
                    print("Лог ошибки сервера: \(serverMessage)")
                    let serverError = NSError(
                        domain: "Network",
                        code: httpResponse.statusCode,
                        userInfo: [NSLocalizedDescriptionKey: "Ошибка сервера. Статус-код: \(httpResponse.statusCode)"]
                    )
                    DispatchQueue.main.async { completion(.failure(serverError)) }
                }
            }
        }
        task.resume()
    }
    func fetchEventDetails(id: String, completion: @escaping (Result<EventDetailModel, Error>) -> Void) {
        guard let url = URL(string: "\(baseUrl)/events/\(id)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = TokenManager.shared.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            guard let data = data else {
                let noDataError = NSError(domain: "Network", code: -1, userInfo: [NSLocalizedDescriptionKey: "Сервер не вернул данные деталей"])
                DispatchQueue.main.async { completion(.failure(noDataError)) }
                return
            }
            do {
                let decoder = JSONDecoder()
                let decodedDetails = try decoder.decode(EventDetailModel.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decodedDetails))
                }
            } catch {
                print("Ошибка декодирования деталей: \(error)")
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
        task.resume()
    }
    func sendTeamApplication(id: String, body: TeamApplicationRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = "\(baseUrl)/event/\(id)/application"
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = TokenManager.shared.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        do {
            let jsonData = try JSONEncoder().encode(body)
            request.httpBody = jsonData
        } catch {
            DispatchQueue.main.async { completion(.failure(error)) }
            return
        }
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                let unknownError = NSError(
                    domain: "Network",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Неизвестный ответ сервера"]
                )
                DispatchQueue.main.async { completion(.failure(unknownError)) }
                return
            }
            if (200...299).contains(httpResponse.statusCode) {
                DispatchQueue.main.async { completion(.success(())) }
            } else {
                let serverMessage = data != nil ? (String(data: data!, encoding: .utf8) ?? "") : ""
                print("Лог ошибки бэкенда при подаче заявки: \(serverMessage)")
                let errorDescription = !serverMessage.isEmpty ? serverMessage : "Ошибка сервера. Статус: \(httpResponse.statusCode)"
                let serverError = NSError(
                    domain: "Network",
                    code: httpResponse.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: errorDescription]
                )
                DispatchQueue.main.async { completion(.failure(serverError)) }
            }
        }.resume()
    }
    func postComment(eventId: String, content: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseUrl)/comment/\(eventId)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = TokenManager.shared.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let body: [String: Any] = ["content": content]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    DispatchQueue.main.async { completion(.success(())) }
                } else {
                    let serverMessage = data != nil ? (String(data: data!, encoding: .utf8) ?? "") : ""
                    print("Лог ошибки бэкенда (комментарии): \(serverMessage) | Статус: \(httpResponse.statusCode)")
                    let errorDescription = !serverMessage.isEmpty ? serverMessage : "Ошибка сервера. Статус: \(httpResponse.statusCode)"
                    let serverError = NSError(
                        domain: "Network",
                        code: httpResponse.statusCode,
                        userInfo: [NSLocalizedDescriptionKey: errorDescription]
                    )
                    DispatchQueue.main.async { completion(.failure(serverError)) }
                }
            }
        }.resume()
    }
    func updateEventDetails(id: String, requestModel: EditEventRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseUrl)/author-events/\(id)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = TokenManager.shared.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(requestModel)
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
                let serverError = NSError(domain: "Server Error", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Код ответа: \(httpResponse.statusCode)"])
                completion(.failure(serverError))
                return
            }
            
            completion(.success(()))
        }.resume()
    }
    func closeRegistration(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseUrl)/participants/\(id)/close") else {
            let urlError = NSError(domain: "Network", code: -1, userInfo: [NSLocalizedDescriptionKey: "Неверный URL"])
            DispatchQueue.main.async { completion(.failure(urlError)) }
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = TokenManager.shared.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    DispatchQueue.main.async { completion(.success(())) }
                } else {
                    let serverMessage = data != nil ? (String(data: data!, encoding: .utf8) ?? "") : ""
                    print("Лог ошибки бэкенда при удалении мероприятия: \(serverMessage) | Статус: \(httpResponse.statusCode)")
                    let errorDescription = !serverMessage.isEmpty ? serverMessage : "Ошибка сервера. Статус: \(httpResponse.statusCode)"
                    let serverError = NSError(
                        domain: "Network",
                        code: httpResponse.statusCode,
                        userInfo: [NSLocalizedDescriptionKey: errorDescription]
                    )
                    DispatchQueue.main.async { completion(.failure(serverError)) }
                }
            }
        }.resume()
    }
    func deleteEvent(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseUrl)/author-events/\(id)") else {
            let urlError = NSError(domain: "Network", code: -1, userInfo: [NSLocalizedDescriptionKey: "Неверный URL"])
            DispatchQueue.main.async { completion(.failure(urlError)) }
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = TokenManager.shared.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    DispatchQueue.main.async { completion(.success(())) }
                } else {
                    let serverMessage = data != nil ? (String(data: data!, encoding: .utf8) ?? "") : ""
                    print("Лог ошибки бэкенда при удалении мероприятия: \(serverMessage) | Статус: \(httpResponse.statusCode)")
                    let errorDescription = !serverMessage.isEmpty ? serverMessage : "Ошибка сервера. Статус: \(httpResponse.statusCode)"
                    let serverError = NSError(
                        domain: "Network",
                        code: httpResponse.statusCode,
                        userInfo: [NSLocalizedDescriptionKey: errorDescription]
                    )
                    DispatchQueue.main.async { completion(.failure(serverError)) }
                }
            }
        }.resume()
    }
    func finishEvent(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = "\(baseUrl)/author-events/\(id)/finish"
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        if let token = TokenManager.shared.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }.resume()
    }
    func cancelEvent(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = "\(baseUrl)/author-events/\(id)/cancel"
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        if let token = TokenManager.shared.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }.resume()
    }
    func uploadEventPhoto(id: String, accessToken: String, imageRawData: Data, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseUrl)/author-events/\(id)/photo") else {
            completion(.failure(NSError(domain: "InvalidURL", code: 400, userInfo: nil)))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        var body = Data()
        let lineBreak = "\r\n"
        body.append("--\(boundary)\(lineBreak)".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"event_photo.jpg\"\(lineBreak)".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\(lineBreak)\(lineBreak)".data(using: .utf8)!)
        body.append(imageRawData)
        body.append(lineBreak.data(using: .utf8)!)
        body.append("--\(boundary)--\(lineBreak)".data(using: .utf8)!)
        request.httpBody = body
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                let statusError = NSError(domain: "ServerError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Код ответа сервера: \(httpResponse.statusCode)"])
                completion(.failure(statusError))
                return
            }
            completion(.success(()))
        }
        task.resume()
    }
}
