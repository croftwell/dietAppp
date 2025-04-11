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
        let _ = print("dietAppApp body re-evaluated. isAuthenticated: \(authViewModel.isAuthenticated)")
        WindowGroup {
            if authViewModel.isAuthenticated {
                let _ = print("Showing ContentView")
                ContentView()
                    .environmentObject(authViewModel)
                    .id("ContentView")
            } else {
                let _ = print("Showing Onboarding Stack")
                NavigationStack {
                    OnboardingView()
                }
                .environmentObject(authViewModel)
                .id("OnboardingStack")
            }
        }
    }
}
