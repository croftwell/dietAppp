import Foundation
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import UIKit
import FirebaseCore
import FirebaseFirestore

@MainActor
class AuthenticationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var errorMessage = ""
    @Published var isLoading = false
    @Published var isAuthenticated = false
    
    private let authService: AuthenticationServiceProtocol
    
    // Auth state listener handle
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    init(authService: AuthenticationServiceProtocol = AuthenticationService()) {
        self.authService = authService
        // Uygulama başladığında kullanıcı durumunu kontrol et
        checkAuthState()
    }
    
    deinit {
        // Listener'ı kaldır
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    private func checkAuthState() {
        // Firebase'in otomatik giriş durumunu kontrol et
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
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
        
        do {
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                throw NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase yapılandırması bulunamadı"])
            }
            
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
            
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first,
                  let rootViewController = window.rootViewController else {
                throw NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Root view controller bulunamadı"])
            }
            
            // Google Sign-In işlemi
            let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            let user = gidSignInResult.user
            
            guard let idToken = user.idToken?.tokenString else {
                throw NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "ID token alınamadı"])
            }
            
            // Önce kullanıcının email adresini kontrol et
            let email = user.profile?.email ?? ""
            let methods = try await Auth.auth().fetchSignInMethods(forEmail: email)
            
            if methods.isEmpty {
                // Kullanıcı daha önce kayıt olmamış
                errorMessage = "Bu email adresi ile kayıtlı hesap bulunamadı. Lütfen önce kayıt olun."
                isLoading = false
                return
            }
            
            // Email kayıtlı, giriş yap
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )
            
            // Google ile giriş yap
            let authResult = try await Auth.auth().signIn(with: credential)
            let uid = authResult.user.uid
            
            // Firestore'da son giriş tarihini güncelle
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(uid)
            
            try? await userRef.updateData([
                "lastLoginAt": Timestamp()
            ])
            
            print("Google ile giriş başarılı: \(uid)")
            isAuthenticated = true
            
        } catch let error as NSError {
            // Google Sign-In veya diğer genel hatalar
            if error.code == GIDSignInError.canceled.rawValue {
                errorMessage = "Giriş işlemi iptal edildi"
            } else {
                errorMessage = "Google ile giriş yapılırken bir hata oluştu: \(error.localizedDescription)"
            }
            isAuthenticated = false
        }
        
        isLoading = false
    }
    
    // Google ile kayıt ol işlemi
    func signUpWithGoogle() async {
        isLoading = true
        errorMessage = ""
        
        do {
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                throw NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase yapılandırması bulunamadı"])
            }
            
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
            
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first,
                  let rootViewController = window.rootViewController else {
                throw NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Root view controller bulunamadı"])
            }
            
            let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            let user = gidSignInResult.user
            
            guard let idToken = user.idToken?.tokenString else {
                throw NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "ID token alınamadı"])
            }
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )
            
            let auth = Auth.auth()
            
            do {
                // Google ile firebase auth'a kayıt ol
                let authResult = try await auth.signIn(with: credential)
                
                // Firestore'a kullanıcı bilgilerini kaydet
                let db = Firestore.firestore()
                let uid = authResult.user.uid
                
                // Kullanıcı verilerini oluştur
                let userData: [String: Any] = [
                    "email": authResult.user.email ?? "",
                    "displayName": authResult.user.displayName ?? "",
                    "photoURL": authResult.user.photoURL?.absoluteString ?? "",
                    "providerId": "google.com",
                    "createdAt": Timestamp(),
                    "lastLoginAt": Timestamp()
                ]
                
                // Firestore'a kaydet
                try await db.collection("users").document(uid).setData(userData)
                
                print("Google ile kayıt başarılı: \(uid)")
                isAuthenticated = true
                
            } catch let error as NSError {
                print("Google ile kayıt hatası: \(error.localizedDescription)")
                errorMessage = "Google ile kayıt olurken bir hata oluştu: \(error.localizedDescription)"
            }
        } catch let error as NSError {
            if error.code == GIDSignInError.canceled.rawValue {
                errorMessage = "Kayıt işlemi iptal edildi"
            } else {
                errorMessage = "Google ile kayıt olurken bir hata oluştu: \(error.localizedDescription)"
            }
        }
        
        isLoading = false
    }
} 