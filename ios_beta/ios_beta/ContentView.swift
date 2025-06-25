//
//  ContentView.swift
//  ios_beta
//
//  Created by S1F on 25/06/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var showDashboard = false
    
    var body: some View {
        if showDashboard {
            DashboardView()
        } else {
            WelcomeView(showDashboard: $showDashboard)
        }
    }
}

struct WelcomeView: View {
    @Binding var showDashboard: Bool
    
    var body: some View {
        VStack {
            Text("你是厨神!")
                .font(.system(size: 46, weight: .bold))
                .foregroundColor(.orange)
                .shadow(radius: 2)
                .padding()
            
            Text("点击任意位置继续")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .onTapGesture {
            withAnimation {
                showDashboard = true
            }
        }
    }
}

struct DashboardView: View {
    var body: some View {
        VStack {
            Text("仪表盘")
                .font(.largeTitle)
                .padding()
            
            Text("即将推出更多功能...")
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6))
    }
}

#Preview {
    ContentView()
}
