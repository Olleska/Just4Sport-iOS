import Foundation

struct TeamApplicationRequest: Encodable {
    let name: String
    let captainNickname: String
    let membersNicknames: [String]
    let contactInformation: String
}
