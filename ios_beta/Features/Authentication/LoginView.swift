import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 标题
                    Text("欢迎回来")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 50)
                    
                    // 登录类型选择
                    Picker("登录类型", selection: $viewModel.isAdmin) {
                        Text("普通用户").tag(false)
                        Text("管理员").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        // 用户名输入框
                        CustomTextField(
                            "用户名",
                            placeholder: "请输入用户名",
                            text: $viewModel.username
                        )
                        
                        // 密码输入框
                        CustomTextField(
                            "密码",
                            placeholder: "请输入密码",
                            text: $viewModel.password,
                            isSecure: true
                        )
                        
                        // 生日输入框（仅普通用户）
                        if !viewModel.isAdmin {
                            CustomTextField(
                                "出生日期",
                                placeholder: "YYYY-MM-DD",
                                text: $viewModel.birthdate
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // 错误信息
                    if viewModel.showError {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.subheadline)
                    }
                    
                    // 登录按钮
                    PrimaryButton(
                        title: viewModel.isLoading ? "登录中..." : "登录"
                    ) {
                        viewModel.login()
                    }
                    .disabled(viewModel.isLoading)
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    LoginView()
} 