import Foundation
import Combine

class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var birthdate = ""
    @Published var isAdmin = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    private let apiService = APIService.shared
    
    func login() {
        isLoading = true
        showError = false
        
        // 创建登录请求体
        let loginData = [
            "username": username,
            "password": password,
            "birthdate": isAdmin ? "" : birthdate
        ]
        
        guard let jsonData = try? JSONEncoder().encode(loginData) else {
            handleError("数据编码错误")
            return
        }
        
        let endpoint = isAdmin ? "/login?type=admin" : "/login?type=birth"
        
        apiService.request<LoginResponse>(
            endpoint: endpoint,
            method: "POST",
            body: jsonData
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.handleError(error.localizedDescription)
                }
            },
            receiveValue: { [weak self] response in
                self?.handleSuccess(response)
            }
        )
        .store(in: &cancellables)
    }
    
    private func handleError(_ message: String) {
        isLoading = false
        showError = true
        errorMessage = message
    }
    
    private func handleSuccess(_ response: LoginResponse) {
        isLoading = false
        // 保存token和用户信息
        UserDefaults.standard.set(response.token, forKey: "authToken")
        // 发送登录成功通知
        NotificationCenter.default.post(name: .userDidLogin, object: nil)
    }
}

// 登录响应模型
struct LoginResponse: Codable {
    let token: String
    let user: User
}

extension Notification.Name {
    static let userDidLogin = Notification.Name("userDidLogin")
} 