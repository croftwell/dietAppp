import Foundation
import FirebaseAuth
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
        } catch let error as NSError {
            switch error.code {
            case AuthErrorCode.emailAlreadyInUse.rawValue:
                self.errorMessage = "Bu email adresi zaten kullanılıyor"
            case AuthErrorCode.invalidEmail.rawValue:
                self.errorMessage = "Geçersiz email adresi"
            case AuthErrorCode.weakPassword.rawValue:
                self.errorMessage = "Şifre çok zayıf, en az 6 karakter olmalıdır"
            case AuthErrorCode.networkError.rawValue:
                self.errorMessage = "İnternet bağlantısı hatası"
            default:
                self.errorMessage = "Kayıt olma işlemi başarısız: \(turkceLestir(error: error))"
            }
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
            case AuthErrorCode.tooManyRequests.rawValue:
                self.errorMessage = "Çok fazla giriş denemesi yaptınız. Lütfen daha sonra tekrar deneyin"
            default:
                self.errorMessage = "Giriş yapılamadı: \(turkceLestir(error: error))"
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
        
        // Email formatı kontrolü
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        guard emailPred.evaluate(with: email) else {
            self.errorMessage = "Lütfen geçerli bir email adresi girin"
            return
        }
        
        self.isLoading = true
        
        do {
            // Direkt şifre sıfırlama isteği gönder
            // Firebase, email sistemde kayıtlı değilse bile hata vermez, sadece email göndermez
            try await authService.resetPassword(email: email)
            self.errorMessage = "Eğer bu email sistemde kayıtlıysa, şifre sıfırlama bağlantısı gönderilecektir"
        } catch let error as NSError {
            switch error.code {
            case AuthErrorCode.userNotFound.rawValue:
                self.errorMessage = "Bu email adresi ile kayıtlı hesap bulunamadı"
            case AuthErrorCode.invalidEmail.rawValue:
                self.errorMessage = "Geçersiz email adresi"
            case AuthErrorCode.networkError.rawValue:
                self.errorMessage = "İnternet bağlantısı hatası"
            case AuthErrorCode.invalidSender.rawValue:
                self.errorMessage = "Geçersiz gönderici adresi"
            case AuthErrorCode.invalidRecipientEmail.rawValue:
                self.errorMessage = "Geçersiz alıcı email adresi"
            case AuthErrorCode.missingEmail.rawValue:
                self.errorMessage = "Email adresi girilmedi"
            default:
                self.errorMessage = "Şifre sıfırlama bağlantısı gönderilemedi: \(turkceLestir(error: error))"
            }
        }
        
        self.isLoading = false
    }
    
    func signOut() {
        do {
            try authService.signOut()
            self.isAuthenticated = false
        } catch {
            self.errorMessage = "Çıkış yapılırken bir hata oluştu"
        }
    }
    
    // Firebase hata mesajlarını Türkçeleştiren yardımcı fonksiyon
    private func turkceLestir(error: NSError) -> String {
        let errorMsg = error.localizedDescription.lowercased()
        
        if errorMsg.contains("network error") {
            return "İnternet bağlantısı hatası"
        } else if errorMsg.contains("wrong password") {
            return "Hatalı şifre"
        } else if errorMsg.contains("user not found") {
            return "Kullanıcı bulunamadı"
        } else if errorMsg.contains("invalid email") {
            return "Geçersiz email adresi"
        } else if errorMsg.contains("email already in use") {
            return "Bu email adresi zaten kullanılıyor"
        } else if errorMsg.contains("weak password") {
            return "Şifre çok zayıf"
        } else if errorMsg.contains("too many requests") {
            return "Çok fazla istek gönderildi. Lütfen daha sonra tekrar deneyin"
        } else if errorMsg.contains("invalid credential") {
            return "Geçersiz kimlik bilgileri"
        } else if errorMsg.contains("credential is malformed or has expired") {
            return "Kimlik bilgileri hatalı veya süresi dolmuş"
        } else if errorMsg.contains("account exists with different credential") {
            return "Bu email adresi farklı bir giriş yöntemi ile kullanılıyor"
        } else if errorMsg.contains("popup closed by user") {
            return "Giriş işlemi kullanıcı tarafından iptal edildi"
        } else if errorMsg.contains("requires recent authentication") {
            return "Bu işlem için yakın zamanda giriş yapılmış olması gerekiyor"
        } else if errorMsg.contains("app not authorized") {
            return "Uygulama yetkilendirilmemiş"
        } else if errorMsg.contains("user disabled") {
            return "Kullanıcı hesabı devre dışı bırakılmış"
        } else if errorMsg.contains("user token expired") {
            return "Oturum süresi dolmuş, lütfen tekrar giriş yapın"
        }
        
        return "Bir hata oluştu"
    }
} 