import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @State private var showResetPassword = false
    @State private var showRegister = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
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
                        placeholder: "E-mail",
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
                
                // --- Sosyal Giriş Ayırıcı --- 
                Divider()
                    .padding(.vertical, 8)

                // --- Apple ile Giriş --- 
                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        print("Apple Sign In Request Started")
                    },
                    onCompletion: { result in
                        print("Apple Sign In Completed")
                    }
                )
                .signInWithAppleButtonStyle(.whiteOutline)
                .frame(height: 50)
                .padding(.horizontal)
                
                // --- Google ile Giriş --- 
                Button {
                    Task {
                        await viewModel.signInWithGoogle()
                    }
                } label: {
                    HStack {
                        Image(systemName: "g.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            
                        Text("Google ile Giriş Yap")
                            .font(.headline)
                    }
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: .gray.opacity(0.3), radius: 2, x: 0, y: 2)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    }
                }
                .padding(.horizontal)
                .disabled(viewModel.isLoading)
                
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
            .navigationDestination(isPresented: $viewModel.isAuthenticated) {
                ContentView()
                    .environmentObject(viewModel)
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationViewModel())
} 