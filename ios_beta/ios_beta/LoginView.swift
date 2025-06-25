import SwiftUI

struct LoginView: View {
    @StateObject private var apiService = APIService()
    @State private var username = ""
    @State private var password = ""
    @State private var birthDate = Date()
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isAdminMode = false
    @State private var isLoading = false
    @Binding var isAuthenticated: Bool
    
    // 获取设备类型和方向
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    // 根据设备类型调整布局
    private var isIPad: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .regular
    }
    
    // 动态调整Logo大小
    private var logoSize: CGFloat {
        isIPad ? 120 : 80
    }
    
    // 动态调整内容边距
    private var contentPadding: CGFloat {
        isIPad ? 60 : 30
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    // 登录类型切换标签
                    HStack(spacing: 0) {
                        // 用户登录标签
                        TabButton(
                            title: "用户登录",
                            isSelected: !isAdminMode,
                            action: { isAdminMode = false }
                        )
                        
                        // 管理员登录标签
                        TabButton(
                            title: "管理员登录",
                            isSelected: isAdminMode,
                            action: { isAdminMode = true }
                        )
                    }
                    .background(Color(.systemGray6))
                    
                    // 主要内容区域
                    VStack(spacing: 20) {
                        // Logo
                        if isAdminMode {
                            Image(systemName: "person.badge.key.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: logoSize, height: logoSize)
                                .foregroundColor(.blue)
                                .padding(.top, isIPad ? 60 : 40)
                        } else {
                            Text("🐣")
                                .font(.system(size: logoSize))
                                .padding(.top, isIPad ? 60 : 40)
                        }
                        
                        // 标题
                        Text(isAdminMode ? "管理员登录" : "用户登录")
                            .font(isIPad ? .title : .title2)
                            .fontWeight(.bold)
                            .padding(.bottom, 20)
                        
                        // 登录表单
                        VStack(spacing: 15) {
                            // 用户名输入框
                            FormField(
                                icon: "person.fill",
                                placeholder: isAdminMode ? "管理员账号" : "用户名",
                                text: $username
                            )
                            
                            // 密码输入框
                            FormField(
                                icon: "lock.fill",
                                placeholder: "请输入密码",
                                text: $password,
                                isSecure: true
                            )
                            
                            // 出生日期选择器（仅用户登录时显示）
                            if !isAdminMode {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("出生日期")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    DatePicker(
                                        "",
                                        selection: $birthDate,
                                        displayedComponents: .date
                                    )
                                    .datePickerStyle(.wheel)
                                    .frame(maxHeight: 100)
                                    .clipped()
                                }
                                .padding(.vertical, 8)
                            }
                            
                            // 错误提示
                            if showError {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                            
                            // 登录按钮
                            Button(action: {
                                Task {
                                    await login()
                                }
                            }) {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else if showError {
                                    Text("重试")
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: isIPad ? 60 : 50)
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                } else {
                                    Text(isAdminMode ? "管理员登录" : "登录")
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: isIPad ? 60 : 50)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                            .disabled(isLoading)
                            .padding(.top, 10)
                        }
                        .padding(.horizontal, contentPadding)
                        
                        // iPad 横屏时添加额外的底部间距
                        if isIPad {
                            Spacer()
                                .frame(height: 40)
                        }
                    }
                    .frame(minHeight: geometry.size.height - (isIPad ? 0 : 44))
                    .background(Color.white)
                }
            }
            .background(Color(.systemGray6))
        }
        .ignoresSafeArea(.keyboard)
    }
    
    private func login() async {
        isLoading = true
        showError = false
        errorMessage = ""
        
        do {
            let response: LoginResponse
            if isAdminMode {
                response = try await apiService.adminLogin(username: username, password: password)
            } else {
                response = try await apiService.userLogin(username: username, password: password, birthDate: birthDate)
            }
            
            if response.success {
                isAuthenticated = true
            } else {
                showError = true
                errorMessage = response.message
            }
        } catch let error as APIError {
            showError = true
            errorMessage = error.message
        } catch {
            showError = true
            errorMessage = "登录失败：\(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

// MARK: - 辅助视图

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    // 获取设备类型
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    // 动态调整标签高度
    private var tabHeight: CGFloat {
        horizontalSizeClass == .regular ? 54 : 44
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: horizontalSizeClass == .regular ? 18 : 16, weight: .medium))
                .foregroundColor(isSelected ? .blue : .gray)
                .frame(maxWidth: .infinity)
                .frame(height: tabHeight)
                .background(isSelected ? Color.white : Color.clear)
        }
    }
}

struct FormField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    // 获取设备类型
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    // 动态调整字体大小
    private var fontSize: CGFloat {
        horizontalSizeClass == .regular ? 18 : 16
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: horizontalSizeClass == .regular ? 24 : 20)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(.system(size: fontSize))
                    .textContentType(.password)
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: fontSize))
                    .textContentType(.username)
            }
        }
        .padding(.vertical, horizontalSizeClass == .regular ? 16 : 12)
        .padding(.horizontal, horizontalSizeClass == .regular ? 20 : 16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Preview
#Preview {
    LoginView(isAuthenticated: .constant(false))
} 