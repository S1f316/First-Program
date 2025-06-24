import Foundation

struct Todo: Identifiable, Decodable {
    let id: Int
    let task: String
    let completed: Bool
}

struct Post: Identifiable, Decodable {
    let id: Int
    let content: String
    let author: String
    let likeCount: Int
    let complaintCount: Int
}
