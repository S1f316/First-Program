import Foundation

struct Post: Identifiable, Codable {
    let id: Int
    var title: String
    var content: String
    var userId: Int
    var username: String
    var createdAt: Date
    var likes: Int
    var complaints: Int
    var comments: [Comment]
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case content
        case userId = "user_id"
        case username
        case createdAt = "created_at"
        case likes
        case complaints
        case comments
    }
}

struct Comment: Identifiable, Codable {
    let id: Int
    var content: String
    var userId: Int
    var username: String
    var postId: Int
    var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case userId = "user_id"
        case username
        case postId = "post_id"
        case createdAt = "created_at"
    }
} 