import Foundation

enum LoginType: String, Codable {
    case admin
    case birth
}

struct User: Identifiable, Codable {
    let id: Int
    var username: String
    var birthdate: String?
    var loginType: LoginType
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case birthdate
        case loginType = "login_type"
    }
} 