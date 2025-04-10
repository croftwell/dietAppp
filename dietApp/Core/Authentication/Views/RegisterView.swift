import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Logo ve başlık
                VStack(spacing: 10) {
                    Image(systemName: "fork.knife.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.green)
                    
                    Text("Yeni Hesap Oluştur")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                .padding(.top, 50)
                
                // Kayıt formu
                VStack(spacing: 15) {
                    CustomTextField(
                        text: $viewModel.email,
                        placeholder: "Email",
                        systemImage: "envelope"
                    )
                    
                    CustomSecureField(
                        text: $viewModel.password,
                        placeholder: "Şifre",
                        systemImage: "lock"
                    )
                    
                    CustomSecureField(
                        text: $viewModel.confirmPassword,
                        placeholder: "Şifre Tekrar",
                        systemImage: "lock"
                    )
                }
                .padding(.horizontal)
                
                // Kayıt ol butonu
                Button {
                    Task {
                        await viewModel.signUp()
                    }
                } label: {
                    CustomButton(
                        title: "Kayıt Ol",
                        backgroundColor: .green
                    )
                }
                .padding(.horizontal)
                .disabled(viewModel.isLoading)
                
                // Giriş yap yönlendirmesi
                HStack {
                    Text("Zaten hesabınız var mı?")
                        .foregroundColor(.gray)
                    
                    Button("Giriş Yap") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                }
                .font(.subheadline)
                .padding(.top, 16)
                
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
        }
    }
}

#Preview {
    RegisterView()
        .environmentObject(AuthenticationViewModel())
} 