import Foundation
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import UIKit
import FirebaseCore

@MainActor
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
        // Uygulama başladığında kullanıcı durumunu kontrol et
        checkAuthState()
    }
    
    private func checkAuthState() {
        // Firebase'in otomatik giriş durumunu kontrol et
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isAuthenticated = user != nil
            }
        }
    }
    
    func signUp() async {
        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            self.errorMessage = "Lütfen tüm alanları doldurun"
            return
        }
        
        guard password == confirmPassword else {
            self.errorMessage = "Şifreler eşleşmiyor"
            return
        }
        
        self.isLoading = true
        
        do {
            try await authService.signUp(email: email, password: password)
            self.isAuthenticated = true
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        self.isLoading = false
    }
    
    func signIn() async {
        guard !email.isEmpty, !password.isEmpty else {
            self.errorMessage = "Lütfen email ve şifrenizi girin"
            return
        }
        
        self.isLoading = true
        
        do {
            try await authService.signIn(email: email, password: password)
            self.isAuthenticated = true
        } catch let error as NSError {
            switch error.code {
            case AuthErrorCode.userNotFound.rawValue:
                self.errorMessage = "Bu email adresi ile kayıtlı hesap bulunamadı"
            case AuthErrorCode.wrongPassword.rawValue:
                self.errorMessage = "Hatalı şifre"
            case AuthErrorCode.invalidEmail.rawValue:
                self.errorMessage = "Geçersiz email adresi"
            case AuthErrorCode.userDisabled.rawValue:
                self.errorMessage = "Bu hesap devre dışı bırakılmış"
            case AuthErrorCode.networkError.rawValue:
                self.errorMessage = "İnternet bağlantısı hatası"
            default:
                self.errorMessage = "Giriş yapılamadı: \(error.localizedDescription)"
            }
        } catch {
            self.errorMessage = "Beklenmeyen bir hata oluştu"
        }
        
        self.isLoading = false
    }
    
    func resetPassword() async {
        guard !email.isEmpty else {
            self.errorMessage = "Lütfen email adresinizi girin"
            return
        }
        
        self.isLoading = true
        
        do {
            try await authService.resetPassword(email: email)
            self.errorMessage = "Şifre sıfırlama bağlantısı email adresinize gönderildi"
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        self.isLoading = false
    }
    
    func signOut() {
        do {
            try authService.signOut()
            self.isAuthenticated = false
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func signInWithGoogle() async {
        isLoading = true
        errorMessage = ""

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            errorMessage = "Aktif pencere bulunamadı."
            isLoading = false
            print("Hata: Aktif pencere bulunamadı.")
            return
        }
        print("Aktif pencere bulundu.")

        guard let clientID = FirebaseApp.app()?.options.clientID else {
            errorMessage = "Firebase Client ID bulunamadı."
            isLoading = false
            print("Hata: Firebase Client ID bulunamadı.")
            return
        }
        print("Firebase Client ID alındı: \(clientID)")

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        print("GIDConfiguration oluşturuldu.")

        do {
            print("GIDSignIn.sharedInstance.signIn çağrılıyor...")
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            print("Google Sign-In başarılı, sonuç alındı.")

            guard let idToken = result.user.idToken?.tokenString else {
                print("Hata: Google ID Token alınamadı.")
                throw URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: "Google ID Token alınamadı."])
            }
            let accessToken = result.user.accessToken.tokenString
            print("ID Token ve Access Token alındı.")

            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: accessToken)
            print("Firebase Google credential oluşturuldu.")

            // Önce kullanıcının email adresini kontrol et
            let email = result.user.profile?.email ?? ""
            let methods = try await Auth.auth().fetchSignInMethods(forEmail: email)
            
            if methods.isEmpty {
                // Kullanıcı daha önce kayıt olmamış
                errorMessage = "Bu email adresi ile kayıtlı hesap bulunamadı. Lütfen önce kayıt olun."
                isLoading = false
                return
            }

            print("Auth.auth().signIn çağrılıyor...")
            let authResult = try await Auth.auth().signIn(with: credential)
            print("Firebase Google ile giriş başarılı! User: \(authResult.user.uid)")

            await MainActor.run {
                self.isAuthenticated = true
                self.isLoading = false
                print("ViewModel durumu güncellendi: isAuthenticated = true, isLoading = false")
            }

        } catch let error as NSError {
            if error.code == GIDSignInError.canceled.rawValue {
                 print("Google ile giriş kullanıcı tarafından iptal edildi.")
                 errorMessage = "Giriş iptal edildi."
            } else {
                 print("Google ile giriş hatası: \(error.localizedDescription), Kod: \(error.code)")
                 errorMessage = "Google ile giriş yapılamadı: \(error.localizedDescription)"
            }
            isLoading = false
        } catch {
            print("Beklenmedik Google ile giriş hatası: \(error.localizedDescription)")
            errorMessage = "Bir hata oluştu: \(error.localizedDescription)"
            isLoading = false
        }
    }
} 