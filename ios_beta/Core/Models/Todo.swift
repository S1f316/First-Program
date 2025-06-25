import Foundation

enum Priority: String, Codable {
    case urgent
    case medium
    case low
}

struct Todo: Identifiable, Codable {
    let id: Int
    var task: String
    var date: String
    var time: String
    var priority: Priority
    var completed: Bool
    var userId: Int
    var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case task
        case date
        case time
        case priority
        case completed
        case userId = "user_id"
        case createdAt = "created_at"
    }
} 