import SwiftUI

struct ResetPasswordView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showAlert = false
    @State private var isSuccess = false
    @State private var showConfirmation = false
    @State private var remainingTime = 120
    @State private var timer: Timer?
    @State private var animateButton = false
    
    var body: some View {
        NavigationStack {
            if showConfirmation {
                confirmationView
            } else {
                inputView
            }
        }
    }
    
    // Email giriş ekranı
    private var inputView: some View {
        VStack(spacing: 20) {
            // Logo ve başlık
            VStack(spacing: 10) {
                Image(systemName: "lock.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.green)
                
                Text("Şifre Sıfırlama")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            .padding(.top, 50)
            
            // Açıklama
            Text("Şifrenizi sıfırlamak için email adresinizi girin. Size şifre sıfırlama bağlantısı göndereceğiz.")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            // Email alanı
            CustomTextField(
                text: $viewModel.email,
                placeholder: "Email",
                systemImage: "envelope"
            )
            .padding(.horizontal)
            
            // İleri butonu
            Button {
                validateAndProceed()
            } label: {
                CustomButton(
                    title: "İleri",
                    backgroundColor: .green
                )
            }
            .padding(.horizontal)
            .disabled(viewModel.isLoading)
            
            Spacer()
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("İptal") {
                    dismiss()
                }
                .foregroundColor(.green)
            }
        }
        .overlay(alignment: .center) {
            if !viewModel.errorMessage.isEmpty && showAlert {
                errorAlert
            }
        }
    }
    
    // Onay ekranı ve zamanlayıcı
    private var confirmationView: some View {
        VStack(spacing: 25) {
            // Başlık ve icon
            VStack(spacing: 15) {
                Image(systemName: "envelope.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.green)
                
                Text("Email Adresinizi Onaylayın")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            .padding(.top, 50)
            
            // Email bilgisi
            VStack(spacing: 8) {
                Text("Şifre sıfırlama bağlantısı gönderilecek email:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text(viewModel.email)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal)
            
            // Zamanlayıcı gösterimi
            if remainingTime > 0 {
                VStack(spacing: 5) {
                    Text("Yeni istek için kalan süre:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(timeString(from: remainingTime))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                        .monospacedDigit()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.1))
                )
            }
            
            // Gönder butonu
            Button {
                Task {
                    await sendResetEmail()
                }
            } label: {
                CustomButton(
                    title: remainingTime > 0 && timer != nil ? "Şifre Sıfırlama Bağlantısı Gönder" : "Tekrar Gönder",
                    backgroundColor: .green
                )
                .opacity(remainingTime > 0 && timer != nil ? 0.5 : 1.0)
                .scaleEffect(remainingTime > 0 && timer != nil ? 1.0 : 1.02)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), 
                           value: remainingTime > 0 && timer != nil)
                .overlay(
                    ZStack {
                        if remainingTime == 0 && timer == nil {
                            Circle()
                                .stroke(Color.green, lineWidth: 2)
                                .scaleEffect(animateButton ? 1.5 : 1.0)
                                .opacity(animateButton ? 0.0 : 0.3)
                        }
                    }
                )
            }
            .padding(.horizontal)
            .disabled(viewModel.isLoading || (remainingTime > 0 && timer != nil))
            
            // Geri buton
            Button {
                showConfirmation = false
                stopTimer()
            } label: {
                Text("Geri")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
            .padding(.top, 10)
            
            Spacer()
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .overlay(alignment: .center) {
            if !viewModel.errorMessage.isEmpty && showAlert {
                errorAlert
            }
        }
    }
    
    // Hata mesajı alert görünümü
    private var errorAlert: some View {
        ZStack {
            // Ekranın tamamını kaplayan yarı saydam gri arka plan
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            // Alert içeriği
            VStack {
                Text(isSuccess ? "Başarılı" : "Hata")
                    .foregroundColor(isSuccess ? .green : .red)
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.bottom, 8)
                
                Text(viewModel.errorMessage)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button {
                    viewModel.errorMessage = ""
                    showAlert = false
                    // Başarılı ise ekranı kapat
                    if isSuccess {
                        dismiss()
                    } else if showConfirmation && remainingTime <= 0 {
                        // Süre dolmuşsa ve hata varsa, yeniden başlat
                        restartTimer()
                    }
                } label: {
                    Text("Tamam")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 120, height: 44)
                        .background(isSuccess ? Color.green : Color.red)
                        .cornerRadius(6)
                }
                .padding(.top, 20)
            }
            .padding(24)
            .frame(width: UIScreen.main.bounds.width * 0.85)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
        }
    }
    
    // Email formatını kontrol et ve onay ekranına geç
    private func validateAndProceed() {
        // Email boş mu?
        guard !viewModel.email.isEmpty else {
            viewModel.errorMessage = "Lütfen email adresinizi girin"
            showAlert = true
            return
        }
        
        // Email formatı geçerli mi?
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        guard emailPred.evaluate(with: viewModel.email) else {
            viewModel.errorMessage = "Lütfen geçerli bir email adresi girin"
            showAlert = true
            return
        }
        
        // Onay ekranına geç
        showConfirmation = true
        remainingTime = 120
        startTimer()
    }
    
    // Şifre sıfırlama emaili gönder
    private func sendResetEmail() async {
        await viewModel.resetPassword()
        showAlert = true
        isSuccess = viewModel.errorMessage.contains("sistemde kayıtlıysa")
        if isSuccess {
            startTimer()
        }
    }
    
    // Zamanlayıcıyı başlat
    private func startTimer() {
        stopTimer() // Varsa önceki zamanlayıcıyı durdur
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                stopTimer()
            }
        }
    }
    
    // Zamanlayıcıyı durdur
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        
        // Buton animasyonunu başlat
        if remainingTime <= 0 {
            startButtonAnimation()
        }
    }
    
    // Buton animasyonu
    private func startButtonAnimation() {
        // Sürekli tekrarlanan bir animasyon
        withAnimation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: false)) {
            animateButton = true
        }
        
        // 5 saniye sonra animasyonu durdur
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            withAnimation {
                animateButton = false
            }
        }
    }
    
    // Zamanlayıcıyı yeniden başlat
    private func restartTimer() {
        remainingTime = 120
        startTimer()
    }
    
    // Saniyeyi dakika:saniye formatına dönüştür
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

#Preview {
    ResetPasswordView()
        .environmentObject(AuthenticationViewModel())
} 