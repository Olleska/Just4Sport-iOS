import Foundation

struct ProfileResponse: Decodable {
    let name: String
    let nickname: String
    let email: String
    let favoriteSports: [String]
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
        case .volleyball: return "Волейбол"
        case .basketball: return "Баскетбол"
        case .ultimate: return "Алтимат"
        case .hockey: return "Хоккей"
        case .soccer: return "Футбол"
        }
    }
}

struct PhotoProfileModel: Decodable {
    let id: String
    let path: String
    let title: String
}
