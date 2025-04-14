import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class ProfileSetupViewModel: ObservableObject {
    @Published var profile = UserProfile()
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var currentStep = 0
    @Published var errorMessage = ""
    @Published var isLoading = false
    @Published var isRegistered = false
    
    private let authService: AuthenticationServiceProtocol
    
    init(authService: AuthenticationServiceProtocol = AuthenticationService()) {
        self.authService = authService
    }
    
    // Kayıt işlemini gerçekleştiren fonksiyon
    func registerUser() async {
        guard validateRegistration() else { return }
        
        self.isLoading = true
        
        do {
            try await authService.signUp(email: profile.email, password: password)
            
            // Kullanıcı profil bilgilerini Firestore'a kaydet
            try await saveUserProfile()
            
            self.isRegistered = true
        } catch let error as NSError {
            handleAuthError(error)
        }
        
        self.isLoading = false
    }
    
    // Kullanıcı profil bilgilerini Firestore'a kaydeden fonksiyon
    private func saveUserProfile() async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "ProfileSetupError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı bulunamadı"])
        }
        
        let db = Firestore.firestore()
        
        // Kullanıcı profil bilgilerini hazırla
        let profileData: [String: Any] = [
            "name": profile.name,
            "username": profile.username,
            "height": profile.height,
            "weight": profile.weight,
            "targetWeight": profile.targetWeight,
            "age": profile.age,
            "gender": profile.gender.rawValue,
            "activityLevel": profile.activityLevel.rawValue,
            "goal": profile.goal.rawValue,
            "dietPreferences": profile.dietPreferences.map { $0.rawValue },
            "mealCount": profile.mealCount,
            "allergies": profile.allergies,
            "createdAt": Timestamp(),
            "updatedAt": Timestamp()
        ]
        
        // Firestore'a kaydet
        try await db.collection("userProfiles").document(userId).setData(profileData)
    }
    
    // Kayıt bilgilerini doğrulayan fonksiyon
    private func validateRegistration() -> Bool {
        // Kullanıcı adı kontrolü
        if profile.username.isEmpty {
            errorMessage = "Lütfen bir kullanıcı adı girin."
            return false
        }
        
        // Email kontrolü
        if profile.email.isEmpty {
            errorMessage = "Lütfen email adresinizi girin."
            return false
        }
        
        // Email formatı kontrolü
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        if !emailPred.evaluate(with: profile.email) {
            errorMessage = "Lütfen geçerli bir email adresi girin."
            return false
        }
        
        // Şifre kontrolü
        if password.isEmpty || confirmPassword.isEmpty {
            errorMessage = "Lütfen şifrenizi girin ve tekrarlayın."
            return false
        }
        
        // Şifre eşleşmesi kontrolü
        if password != confirmPassword {
            errorMessage = "Şifreler eşleşmiyor."
            return false
        }
        
        // Şifre uzunluğu kontrolü
        if password.count < 6 {
            errorMessage = "Şifre en az 6 karakter olmalıdır."
            return false
        }
        
        // Temel profil bilgileri kontrolü
        if profile.height <= 0 || profile.weight <= 0 || profile.age <= 0 {
            errorMessage = "Lütfen geçerli boy, kilo ve yaş bilgilerinizi girin."
            return false
        }
        
        return true
    }
    
    // Firebase hata işleme
    private func handleAuthError(_ error: NSError) {
        switch error.code {
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            self.errorMessage = "Bu email adresi zaten kullanılıyor."
        case AuthErrorCode.invalidEmail.rawValue:
            self.errorMessage = "Geçersiz email adresi."
        case AuthErrorCode.weakPassword.rawValue:
            self.errorMessage = "Şifre çok zayıf, en az 6 karakter olmalıdır."
        case AuthErrorCode.networkError.rawValue:
            self.errorMessage = "İnternet bağlantısı hatası."
        default:
            self.errorMessage = "Kayıt işlemi başarısız: \(error.localizedDescription)"
        }
    }
    
    // Sonraki adıma geçer
    func nextStep() {
        if currentStep < 5 { // 5 adım olduğunu varsayıyoruz: Genel, Boy/Kilo, Aktivite, Diyet, Hesap
            currentStep += 1
        }
    }
    
    // Önceki adıma döner
    func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }
} 