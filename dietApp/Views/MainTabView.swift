import SwiftUI
import FirebaseAuth

struct MainTabView: View {
    @EnvironmentObject private var authViewModel: AuthenticationViewModel
    
    var body: some View {
        TabView {
            // Ana Sayfa
            VStack(spacing: 20) {
                // Hoş geldin mesajı
                VStack(spacing: 10) {
                    Text("Hoş Geldiniz")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    if let user = Auth.auth().currentUser {
                        Text(user.displayName ?? user.email ?? "Kullanıcı")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.top, 20)
                
                // Günlük özet kartı
                VStack(spacing: 15) {
                    Text("Günlük Özet")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    HStack(spacing: 20) {
                        VStack {
                            Text("1,200")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            Text("Kalori")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        VStack {
                            Text("2.5")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            Text("Su (L)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        VStack {
                            Text("8,000")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            Text("Adım")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(.systemGray6))
                )
                .padding(.horizontal)
                
                Spacer()
            }
            .tabItem {
                Label("Ana Sayfa", systemImage: "house.fill")
            }
            
            // Profil Sayfası
            VStack(spacing: 20) {
                if let user = Auth.auth().currentUser {
                    VStack(spacing: 15) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.green)
                        
                        Text(user.displayName ?? "İsimsiz Kullanıcı")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(user.email ?? "")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    
                    Button {
                        authViewModel.signOut()
                    } label: {
                        Text("Çıkış Yap")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .tabItem {
                Label("Profil", systemImage: "person.fill")
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthenticationViewModel())
} 