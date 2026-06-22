import Foundation

struct TeamApplicationRequest: Encodable {
    let name: String
    let captainNickname: String
    let membersNicknames: [String]
    let contactInformation: String
}

struct ParticipantTeamModel: Codable {
    let id: String
    let name: String
    let captain: UserModel?
    let teamMembers: [UserModel]?
}

struct UserModel: Codable {
    let id: String
    let name: String
    let nickname: String
}
