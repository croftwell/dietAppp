import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol AuthenticationServiceProtocol {
    func signUp(email: String, password: String) async throws
    func signIn(email: String, password: String) async throws
    func resetPassword(email: String) async throws
    func signOut() throws
    func saveUserToFirestore(user: User) async throws
}

class AuthenticationService: AuthenticationServiceProtocol {
    func signUp(email: String, password: String) async throws {
        // Firebase Auth'a kullanıcı oluştur
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        
        // Firestore'a kullanıcı bilgilerini kaydet
        try await saveUserToFirestore(user: authResult.user)
    }
    
    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func saveUserToFirestore(user: User) async throws {
        let db = Firestore.firestore()
        
        // Kullanıcı bilgilerini hazırla
        let userData: [String: Any] = [
            "email": user.email ?? "",
            "displayName": user.displayName ?? "",
            "photoURL": user.photoURL?.absoluteString ?? "",
            "providerId": user.providerID,
            "createdAt": Timestamp(),
            "lastLoginAt": Timestamp()
        ]
        
        // Firestore'a kaydet
        try await db.collection("users").document(user.uid).setData(userData)
    }
} 