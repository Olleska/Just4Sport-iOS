import Foundation

struct EventResponse: Decodable {
    let content: [EventModel]
    let last: Bool
    let number: Int
    let totalPages: Int
    let totalElements: Int
}

struct EventModel: Decodable {
    let id: String
    let name: String
    let cost: Int
    let dateStart: String
    let dateEnd: String
    let eventStatus: String
    let eventType: String
    let skillLevel: String
    let sport: String
    let photo: PhotoModel?
    let description: String?
    
    var visibleEventName: String {
        switch eventType {
        case "TRAINING": return "тренировка"
        case "TOURNAMENT": return "турнир"
        case "GAME": return "игра"
        default: return eventType.lowercased()
        }
    }
    var visibleEventStatus: String {
        switch eventStatus {
        case "WILL_BE": return "предстоит"
        case "UNDERWAY": return "в процессе"
        case "FINISHED": return "завершено"
        case "CANCELLED": return "отменено"
        default: return eventStatus.lowercased()
        }
    }
    var visibleSkillLevel: String {
        switch skillLevel {
        case "START": return "новички"
        case "MEDIUM": return "любители"
        case "HARD": return "профeссионалы"
        default: return skillLevel.lowercased()
        }
    }
    var visibleSport: String {
        switch sport {
        case "BASKETBALL": return "баскетбол"
        case "VOLLEYBALL": return "волейбол"
        case "HOCKEY": return "хоккей"
        case "ULTIMATE": return "алтимат"
        case "SOCCER": return "футбол"
        default: return sport.lowercased()
        }
    }
    var visibleStartDate: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let fallbackFormatter = DateFormatter()
        fallbackFormatter.locale = Locale(identifier: "en_US_POSIX")
        if dateStart.contains(".") {
            fallbackFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        } else {
            fallbackFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        }
        guard let date = fallbackFormatter.date(from: dateStart) else { return "Скоро" }
        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "ru_RU")
        outputFormatter.dateFormat = "d MMMM"
        return outputFormatter.string(from: date)
    }
    var visibleEndDate: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let fallbackFormatter = DateFormatter()
        fallbackFormatter.locale = Locale(identifier: "en_US_POSIX")
        if dateEnd.contains(".") {
            fallbackFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        } else {
            fallbackFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        }
        guard let date = fallbackFormatter.date(from: dateEnd) else { return "Скоро" }
        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "ru_RU")
        outputFormatter.dateFormat = "d MMMM"
        return outputFormatter.string(from: date)
    }
}

struct PhotoModel: Decodable {
    let id: String
    let path: String
    let title: String
}

struct EventCreateModel: Encodable {
    let name: String
    let description: String?
    let dateStart: String
    let dateEnd: String
    let place: String
    let cost: Double
    let sport: String
    let eventType: String
    let skillLevel: String
    let deadline: String
    let teamsNumber: Int
}

struct EventFilterParameters {
    var name: String?
    var sport: String?
    var eventType: String?
    var skillLevel: String?
    var status: String?
    var sortField: String?
    var sortDirection: String?
    var costStart: Int?
    var costEnd: Int?
    var dateStart: String?
    var dateEnd: String?
}
