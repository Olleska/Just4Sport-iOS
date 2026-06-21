import Foundation

struct EventDetailModel: Decodable {
    let id: String
    let name: String
    let cost: Int
    let dateStart: String
    let dateEnd: String
    let deadline: String
    let description: String?
    let eventStatus: String
    let eventType: String
    let skillLevel: String
    let sport: String
    let place: String?
    let teamsNumber: Int?
    let author: AuthorModel?
    let comments: [CommentModel]?
    let teams: [ParticipantTeamModel]
    let photo: PhotoModel?
}

struct AuthorModel: Decodable {
    let id: String
    let name: String
    let nickname: String?
}

struct CommentModel: Decodable {
    let id: String
    let authorId: String
    let authorName: String
    let content: String
    let parentId: String?
}

extension EventDetailModel {
    var visibleSport: String {
        switch sport.uppercased() {
        case "BASKETBALL": return "баскетбол"
        case "VOLLEYBALL": return "волейбол"
        case "HOCKEY": return "хоккей"
        case "ULTIMATE": return "алтимат"
        case "SOCCER": return "футбол"
        default: return sport
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
        switch skillLevel.uppercased() {
        case "START": return "новички"
        case "MEDIUM": return "любители"
        case "HARD": return "профeссионалы"
        default: return skillLevel
        }
    }
    var visibleEventName: String {
        switch eventType {
        case "TRAINING": return "тренировка"
        case "TOURNAMENT": return "турнир"
        case "GAME": return "игра"
        default: return eventType.lowercased()
        }
    }
    var visibleStartDate: String {
        formatIsoDate(dateStart)
    }
    
    var visibleEndDate: String {
        formatIsoDate(dateEnd)
    }
    var visibleDeadline: String {
        formatIsoDate(deadline)
    }
    private func formatIsoDate(_ isoString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        let cleanString = isoString.trimmingCharacters(in: .whitespacesAndNewlines)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = dateFormatter.date(from: cleanString) {
            return convertToString(date)
        }
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        if let date = dateFormatter.date(from: cleanString) {
            return convertToString(date)
        }
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = isoFormatter.date(from: cleanString) {
            return convertToString(date)
        }
        return isoString
    }
    private func convertToString(_ date: Date) -> String {
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "d MMMM в HH:mm"
        outputFormatter.locale = Locale(identifier: "ru_RU")
        return outputFormatter.string(from: date)
    }
    var visibleCost: String {
        return cost == 0 ? "Бесплатно" : "\(cost) ₽"
    }
    var visibleTeamsList: String {
        if teams.isEmpty {
            return "Команд пока нет"
        }
        return teams.map { $0.name }.joined(separator: ", ")
    }
}
