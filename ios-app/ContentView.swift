import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = false

    var body: some View {
        NavigationView {
            if isLoggedIn {
                DashboardView()
            } else {
                LoginView(onLogin: {
                    self.isLoggedIn = true
                })
            }
        }
    }
}

struct DashboardView: View {
    var body: some View {
        List {
            NavigationLink("Todos", destination: TodoListView())
            NavigationLink("Forum", destination: ForumView())
        }
        .navigationTitle("Dashboard")
    }
}

struct LoginView: View {
    var onLogin: () -> Void
    @State private var username = ""
    @State private var password = ""
    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .textFieldStyle(.roundedBorder)
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
            Button("Login") {
                // TODO: Perform actual login via API
                onLogin()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Login")
    }
}

struct TodoListView: View {
    @State private var todos: [Todo] = []
    var body: some View {
        List(todos) { todo in
            HStack {
                Image(systemName: todo.completed ? "checkmark.circle.fill" : "circle")
                Text(todo.task)
            }
        }
        .navigationTitle("Todos")
        .onAppear {
            Task {
                todos = await ApiService.shared.fetchTodos()
            }
        }
    }
}

struct ForumView: View {
    @State private var posts: [Post] = []
    var body: some View {
        List(posts) { post in
            VStack(alignment: .leading) {
                Text(post.author)
                    .font(.headline)
                Text(post.content)
                HStack {
                    Label("\(post.likeCount)", systemImage: "hand.thumbsup")
                    Label("\(post.complaintCount)", systemImage: "flag")
                }
                .font(.caption)
            }
        }
        .navigationTitle("Forum")
        .onAppear {
            Task {
                posts = await ApiService.shared.fetchPosts()
            }
        }
    }
}

#Preview {
    ContentView()
}
