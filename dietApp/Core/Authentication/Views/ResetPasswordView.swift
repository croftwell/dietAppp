import SwiftUI

struct ResetPasswordView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
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
                
                // Gönder butonu
                Button {
                    Task {
                        await viewModel.resetPassword()
                    }
                } label: {
                    CustomButton(
                        title: "Gönder",
                        backgroundColor: .green
                    )
                }
                .padding(.horizontal)
                .disabled(viewModel.isLoading)
                
                Spacer()
            }
            .padding()
            .alert("Hata", isPresented: .constant(!viewModel.errorMessage.isEmpty)) {
                Button("Tamam") {
                    viewModel.errorMessage = ""
                }
            } message: {
                Text(viewModel.errorMessage)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                    .foregroundColor(.green)
                }
            }
        }
    }
}

#Preview {
    ResetPasswordView()
        .environmentObject(AuthenticationViewModel())
} 