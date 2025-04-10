import SwiftUI

// Onboarding sayfa verilerini tutan struct (Projenin başka yerinde tanımlı olduğunu varsayıyoruz)
// struct OnboardingPage: Identifiable { ... } 

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var animateBackground = false
    
    // Onboarding sayfaları (Veri yapısı projenizde tanımlı olmalı)
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            image: "fork.knife.circle.fill",
            title: "Diet App'e Hoş Geldiniz",
            description: "Beslenme alışkanlıklarınızı takip etmek ve sağlıklı yaşam için ideal çözüm.",
            gradient: [Color(hex: "2E7D32"), Color(hex: "4CAF50")]
        ),
        OnboardingPage(
            image: "heart.circle.fill",
            title: "Sağlıklı Beslenin",
            description: "Günlük kalori takibi, besin değerleri ve sağlıklı beslenme önerileri.",
            gradient: [Color(hex: "388E3C"), Color(hex: "66BB6A")]
        ),
        OnboardingPage(
            image: "chart.line.uptrend.xyaxis.circle.fill",
            title: "İlerlemenizi Takip Edin",
            description: "Diyet hedeflerinize ulaşma yolculuğunuzu görsel grafiklerle takip edin.",
            gradient: [Color(hex: "43A047"), Color(hex: "81C784")]
        )
    ]
    
    var body: some View {
        GeometryReader { geometry in // Ekran/konteyner boyutunu almak için
            let size = geometry.size // Daha kolay erişim için

            ZStack {
                // Animasyonlu arka plan katmanı
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "E8F5E9"),
                            Color(hex: "C8E6C9"),
                            Color(hex: "A5D6A7")
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    // Animasyonlu desenler
                    Circle()
                        .fill(Color(hex: "81C784").opacity(0.15))
                        .frame(width: 300, height: 300)
                        .offset(x: animateBackground ? -100 : 100, y: animateBackground ? -100 : 100)
                        .animation(
                            Animation.easeInOut(duration: 8)
                                .repeatForever(autoreverses: true),
                            value: animateBackground
                        )
                    
                    Circle()
                        .fill(Color(hex: "4CAF50").opacity(0.15))
                        .frame(width: 200, height: 200)
                        .offset(x: animateBackground ? 100 : -100, y: animateBackground ? 100 : -100)
                        .animation(
                            Animation.easeInOut(duration: 6)
                                .repeatForever(autoreverses: true),
                            value: animateBackground
                        )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Tüm alanı kapla
                .ignoresSafeArea() // Safe area'yı yok say
                .onAppear {
                    animateBackground = true
                }
                
                // İçerik katmanı
                VStack {
                    // TabView'ı içeren ve yüksekliği sınırlı VStack
                    VStack {
                        TabView(selection: $currentPage) {
                            ForEach(pages.indices, id: \.self) { index in
                                // OnboardingCardView'a boyut bilgilerini iletiyoruz
                                OnboardingCardView(page: pages[index], size: size)
                                    .tag(index) // Sayfa index'ini belirle
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never)) // Sayfa görünümü ve göstergeyi gizle
                    }
                    // Yüksekliği ekran yüksekliğinin oranına göre ayarla
                    .frame(height: size.height * 0.75)
                    
                    Spacer() // Kart alanı ile alt kontrolleri ayırır
                    
                    // Sayfa göstergesi
                    HStack(spacing: 12) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Capsule()
                                .fill(currentPage == index ? pages[index].gradient[0] : Color.gray.opacity(0.3))
                                .frame(width: currentPage == index ? 30 : 8, height: 8)
                                .animation(.spring(), value: currentPage)
                        }
                    }
                    .padding(.bottom, 20) // Alt boşluk
                    
                    // Kayıt Ol butonu -> NavigationLink
                    NavigationLink {
                        RegisterView()
                    } label: {
                        CustomButton( // CustomButton kullanımını varsayıyoruz
                            title: "Kayıt Ol",
                            backgroundColor: pages[currentPage].gradient[0]
                        )
                        .padding(.horizontal)
                    }
                    
                    // Giriş Yap yönlendirmesi -> NavigationLink
                    NavigationLink {
                        LoginView()
                    } label: {
                        HStack {
                            Text("Zaten üye misin?")
                                .foregroundColor(.gray)

                            Text("Giriş Yap")
                                .fontWeight(.semibold)
                                .foregroundColor(pages[currentPage].gradient[0])
                        }
                        .font(.subheadline)
                        .padding(.top, 16)
                        .padding(.bottom, 20) // Alt kenardan boşluk
                    }
                }
                // İçerik VStack'i safe area'yı yok saymaz, güvenli alanda kalır
            }
        }
    }
    
    // Her bir onboarding sayfasının içeriğini gösteren basit View
    // Artık boyut bilgilerini parametre olarak alıyor
    private func OnboardingCardView(page: OnboardingPage, size: CGSize) -> some View {
        // Boyutları gelen 'size' parametresine göre hesapla
        let cardWidth = size.width * 0.85
        let cardHeight = cardWidth * 1.2
        let iconSize = cardWidth * 0.25
        let iconImageSize = cardWidth * 0.15

        return VStack(spacing: cardWidth * 0.05) {
            ZStack {
                Circle()
                    .fill(page.gradient[0].opacity(0.1))
                    .frame(width: iconSize, height: iconSize)
                
                Image(systemName: page.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconImageSize, height: iconImageSize)
                    .foregroundColor(page.gradient[0])
            }
            .padding(.top, cardWidth * 0.15) // İçerik üst boşluğu
            
            Text(page.title)
                .font(.system(size: cardWidth * 0.08, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .padding(.top, cardWidth * 0.08)
            
            Text(page.description)
                .font(.system(size: cardWidth * 0.05, weight: .medium, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, cardWidth * 0.08)
                .padding(.top, cardWidth * 0.05)
            
            Spacer(minLength: 0) // Kart içeriğini yukarı iter
        }
        .padding(cardWidth * 0.05) // Kartın iç kenar boşlukları
        .frame(width: cardWidth, height: cardHeight) // Kartın boyutları
        .background(
            RoundedRectangle(cornerRadius: cardWidth * 0.08)
                .fill(.background) // Sistem temasına uygun arka plan
                .shadow(color: Color.black.opacity(0.1), radius: cardWidth * 0.05, x: 0, y: cardWidth * 0.01)
        )
        .overlay(
            RoundedRectangle(cornerRadius: cardWidth * 0.08)
                .stroke(LinearGradient(
                    gradient: Gradient(colors: page.gradient),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ), lineWidth: cardWidth * 0.008)
        )
    }
}

// --- Gerekli Olabilecek Uzantılar / Özel Yapılar ---

// Color(hex:) uzantısı (Varsayım - Projenizde tanımlı olmalı)
/*
 extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0) // Varsayılan renk (örn. siyah)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
 }
 */

// CustomButton (Varsayım - Projenizde tanımlı olmalı)
/*
 struct CustomButton: View {
     let title: String
     let backgroundColor: Color
     var foregroundColor: Color = .white // Varsayılan beyaz yazı rengi
     var action: (() -> Void)? = nil // Action opsiyonel

     var body: some View {
         if let action = action {
             Button(action: action) {
                 buttonLabel
             }
         } else {
            // NavigationLink label'ı için sadece görsel kısım
             buttonLabel
         }
     }

     private var buttonLabel: some View {
         Text(title)
             .font(.headline)
             .foregroundColor(foregroundColor)
             .frame(maxWidth: .infinity)
             .frame(height: 50)
             .background(backgroundColor)
             .cornerRadius(10)
             .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 5)
     }
 }
 */

// #Preview bloğu korunuyor
#Preview("Onboarding View") {
    NavigationStack {
        OnboardingView()
            // Preview için environment object gerekliyse eklenir
            // .environmentObject(AuthenticationViewModel())
    }
} 