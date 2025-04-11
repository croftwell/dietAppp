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
                    HStack(spacing: 12) {
                        Image("google_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            
                        Text("Google ile Giriş Yap")
                            .font(.headline)
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.white)
                    .cornerRadius(6)
                    .overlay {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.black.opacity(0.7), lineWidth: 1)
                    }
                }
                .padding(.horizontal)
                .disabled(viewModel.isLoading)
                
                Spacer()
            }
            .navigationBarBackButtonHidden(true)
            .padding()
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
            .overlay(alignment: .center) {
                if !viewModel.errorMessage.isEmpty {
                    ZStack {
                        // Ekranın tamamını kaplayan yarı saydam gri arka plan
                        Color.black.opacity(0.5)
                            .ignoresSafeArea()
                        
                        // Alert içeriği
                        VStack {
                            Text("Hata")
                                .foregroundColor(.green)
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
                            } label: {
                                Text("Tamam")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(width: 120, height: 44)
                                    .background(Color.green)
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
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationViewModel())
} 