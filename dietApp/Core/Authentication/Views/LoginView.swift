import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @State private var showResetPassword = false
    @State private var showRegister = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            // Geri tuşu
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.green)
                }
                .padding(.leading)
                
                Spacer()
            }
            
            // Logo ve başlık
            VStack(spacing: 10) {
                Image(systemName: "fork.knife.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.green)
                
                Text("Diet App")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            .padding(.top, 20)
            
            // Giriş formu
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
            }
            .padding(.horizontal)
            
            // Şifremi unuttum
            Button {
                showResetPassword = true
            } label: {
                Text("Şifremi Unuttum")
                    .font(.subheadline)
                    .foregroundColor(.green)
            }
            .padding(.top, 5)
            
            // Giriş yap butonu
            Button {
                Task {
                    await viewModel.signIn()
                }
            } label: {
                CustomButton(
                    title: "Giriş Yap",
                    backgroundColor: .green
                )
            }
            .padding(.horizontal)
            .disabled(viewModel.isLoading)
            
            // Kayıt ol yönlendirmesi
            HStack {
                Text("Hesabınız yok mu?")
                    .foregroundColor(.gray)
                
                Button {
                    showRegister = true
                } label: {
                    Text("Kayıt Ol")
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
            .font(.subheadline)
            .padding(.top, 16)
            
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .padding()
        .alert("Hata", isPresented: .constant(!viewModel.errorMessage.isEmpty)) {
            Button("Tamam") {
                viewModel.errorMessage = ""
            }
        } message: {
            Text(viewModel.errorMessage)
        }
        .sheet(isPresented: $showResetPassword) {
            ResetPasswordView()
        }
        .sheet(isPresented: $showRegister) {
            RegisterView()
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationViewModel())
} 