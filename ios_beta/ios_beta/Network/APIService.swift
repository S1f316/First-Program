import Foundation

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    case serverError(String)
    
    var message: String {
        switch self {
        case .invalidURL:
            return "无效的URL"
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        case .invalidResponse:
            return "服务器响应无效"
        case .decodingError:
            return "数据解析错误"
        case .serverError(let message):
            return message
        }
    }
}

// 登录响应模型
struct LoginResponse: Codable {
    let success: Bool
    let message: String
    let token: String?
    let user: UserData?
}

// 用户数据模型
struct UserData: Codable {
    let id: Int
    let username: String
    let birthDate: String?
    let isAdmin: Bool
}

@MainActor
class APIService: ObservableObject {
    // 使用您的实际后端 URL
    private let baseURL = "http://127.0.0.1:5000"
    
    // 用户登录
    func userLogin(username: String, password: String, birthDate: Date?) async throws -> LoginResponse {
        guard let url = URL(string: "\(baseURL)/login") else {
            throw APIError.invalidURL
        }
        
        // 格式化出生日期
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let birthDateString = birthDate.map { dateFormatter.string(from: $0) }
        
        // 构建请求体
        let body: [String: Any] = [
            "username": username,
            "password": password,
            "birth_date": birthDateString ?? "",
            "is_admin": false
        ]
        
        return try await performLogin(url: url, body: body)
    }
    
    // 管理员登录
    func adminLogin(username: String, password: String) async throws -> LoginResponse {
        guard let url = URL(string: "\(baseURL)/login") else {
            throw APIError.invalidURL
        }
        
        // 构建请求体
        let body: [String: Any] = [
            "username": username,
            "password": password,
            "is_admin": true
        ]
        
        return try await performLogin(url: url, body: body)
    }
    
    // 执行登录请求
    private func performLogin(url: URL, body: [String: Any]) async throws -> LoginResponse {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        // 检查响应状态码
        if httpResponse.statusCode == 200 {
            let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
            return loginResponse
        } else {
            // 尝试解析错误消息
            if let errorResponse = try? JSONDecoder().decode(LoginResponse.self, from: data) {
                throw APIError.serverError(errorResponse.message)
            } else {
                throw APIError.serverError("登录失败: HTTP \(httpResponse.statusCode)")
            }
        }
    }
} 