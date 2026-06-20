import Foundation

struct ProfileResponse: Decodable {
    let id: String?
    let name: String
    let nickname: String
    let email: String
    let favoriteSports: [String]
    let photo: PhotoProfileModel?
    let authorEvents: [ProfileEvent]
    let participantEvents: [ProfileEvent]
}

struct ProfileEvent: Decodable {
    let id: String
    let name: String
    let cost: Int
    let dateStart: String
    let dateEnd: String
    let eventStatus: String
    let eventType: String
    let skillLevel: String
    let sport: String
    let photo: PhotoProfileModel?
}

enum SportType: String {
    case volleyball = "VOLLEYBALL"
    case basketball = "BASKETBALL"
    case ultimate = "ULTIMATE"
    case hockey = "HOCKEY"
    case soccer = "SOCCER"
    
    var visibleName: String {
        switch self {
        case .volleyball: return "волейбол"
        case .basketball: return "баскетбол"
        case .ultimate: return "алтимат"
        case .hockey: return "хоккей"
        case .soccer: return "футбол"
        }
    }
}

enum EventStatus: String {
    case WILL_BE = "WILL_BE"
    case UNDERWAY = "STARTED"
    case FINISHED = "FINISHED"
    case CANCELLED = "CANCELLED"
    
    var visibleStatus: String {
        switch self {
        case .WILL_BE: return "предстоит"
        case .UNDERWAY: return "в процессе"
        case .FINISHED: return "завершено"
        case .CANCELLED: return "отменено"
        }
    }
}

enum SkillLevel: String {
    case START = "START"
    case MEDIUM = "MEDIUM"
    case HARD = "HARD"
    
    var visibaleSkillLevel: String {
        switch self {
        case .START: return "новички"
        case .MEDIUM: return "любители"
        case .HARD: return "профессионалы"
        }
    }
}

enum EventType: String {
    case GAME = "GAME"
    case TRAINING = "TRAINING"
    case TOURNAMENT = "TOURNAMENT"
    
    var visibaleType: String {
        switch self {
        case .GAME: return "игра"
        case .TRAINING: return "тренировка"
        case .TOURNAMENT: return "турнир"
        }
    }
}

struct PhotoProfileModel: Decodable {
    let id: String
    let path: String
    let title: String
}

enum EventRole {
    case author
    case participant
}

struct UpdateProfileRequest: Encodable {
    let name: String
    let nickname: String
    let email: String
    let favoriteSports: [String]
}
