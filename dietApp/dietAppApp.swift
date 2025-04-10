//
//  dietAppApp.swift
//  dietApp
//
//  Created by Mehmet ali Çavuşlu on 10.04.2025.
//

import SwiftUI

@main
struct dietAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var authViewModel = AuthenticationViewModel()
    
    var body: some Scene {
        WindowGroup {
            if authViewModel.isAuthenticated {
                ContentView()
                    .environmentObject(authViewModel)
            } else {
                NavigationStack {
                    OnboardingView()
                }
                .environmentObject(authViewModel)
            }
        }
    }
}
