import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Text("Ana Sayfa")
                .tabItem {
                    Label("Ana Sayfa", systemImage: "house.fill")
                }
            
            Text("Profil")
                .tabItem {
                    Label("Profil", systemImage: "person.fill")
                }
        }
    }
}

#Preview {
    MainTabView()
} 