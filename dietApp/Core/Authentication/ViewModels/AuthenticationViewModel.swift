import Foundation
import FirebaseAuth

class AuthenticationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var errorMessage = ""
    @Published var isLoading = false
    @Published var isAuthenticated = false
    
    private let authService: AuthenticationServiceProtocol
    
    init(authService: AuthenticationServiceProtocol = AuthenticationService()) {
        self.authService = authService
    }
    
    func signUp() async {
        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            DispatchQueue.main.async {
                self.errorMessage = "Lütfen tüm alanları doldurun"
            }
            return
        }
        
        guard password == confirmPassword else {
            DispatchQueue.main.async {
                self.errorMessage = "Şifreler eşleşmiyor"
            }
            return
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        do {
            try await authService.signUp(email: email, password: password)
            DispatchQueue.main.async {
                self.isAuthenticated = true
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
        
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
    
    func signIn() async {
        guard !email.isEmpty, !password.isEmpty else {
            DispatchQueue.main.async {
                self.errorMessage = "Lütfen email ve şifrenizi girin"
            }
            return
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        do {
            try await authService.signIn(email: email, password: password)
            DispatchQueue.main.async {
                self.isAuthenticated = true
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
        
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
    
    func resetPassword() async {
        guard !email.isEmpty else {
            DispatchQueue.main.async {
                self.errorMessage = "Lütfen email adresinizi girin"
            }
            return
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        do {
            try await authService.resetPassword(email: email)
            DispatchQueue.main.async {
                self.errorMessage = "Şifre sıfırlama bağlantısı email adresinize gönderildi"
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
        
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
    
    func signOut() {
        do {
            try authService.signOut()
            DispatchQueue.main.async {
                self.isAuthenticated = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }
} 