import Foundation
import FirebaseAuth

protocol AuthenticationServiceProtocol {
    func signUp(email: String, password: String) async throws
    func signIn(email: String, password: String) async throws
    func resetPassword(email: String) async throws
    func signOut() throws
}

class AuthenticationService: AuthenticationServiceProtocol {
    func signUp(email: String, password: String) async throws {
        try await Auth.auth().createUser(withEmail: email, password: password)
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
} 