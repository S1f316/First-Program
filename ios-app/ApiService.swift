import Foundation

final class ApiService {
    static let shared = ApiService()
    private init() {}

    private let baseURL = URL(string: "http://localhost:5000")!

    func fetchTodos() async -> [Todo] {
        guard let url = URL(string: "/api/todos", relativeTo: baseURL) else {
            return []
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let todos = try JSONDecoder().decode([Todo].self, from: data)
            return todos
        } catch {
            print("Fetch todos failed: \(error)")
            return []
        }
    }

    func fetchPosts() async -> [Post] {
        guard let url = URL(string: "/api/posts", relativeTo: baseURL) else {
            return []
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let posts = try JSONDecoder().decode([Post].self, from: data)
            return posts
        } catch {
            print("Fetch posts failed: \(error)")
            return []
        }
    }
}
