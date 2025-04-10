//
//  ContentView.swift
//  dietApp
//
//  Created by Mehmet ali Çavuşlu on 10.04.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MainTabView()
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthenticationViewModel())
}
