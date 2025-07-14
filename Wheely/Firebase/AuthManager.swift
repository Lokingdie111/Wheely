//
//  AuthManager.swift
//  Wheely
//
//  Created by 민현규 on 7/11/25.
//

import Foundation
import FirebaseAuth


struct UserInfo {
    var email: String?
    var uid: String?
    var displayName: String?
}
@MainActor
class AuthManager: ObservableObject {
    /// Check this value to check user currently logged in.
    @Published var isUserLogin: Bool = false
    /// User info stored by UserInfo struct.
    @Published var userInfo: UserInfo?
    
    var errorBuffer: AuthErrorCode?
    
    var handle: AuthStateDidChangeListenerHandle?
    
    /// Sign in by fireAuth
    ///
    /// If failed to sign in, this method will print debug message.
    /// - Parameters:
    ///     - email: User email
    ///     - password: User password
    /// - Returns: Return true when signin succesfully, return false when sigin failed.
    public func signIn(email: String, password: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if result != nil {
                    print("[AuthManager] Sign In Successfully.")
                    continuation.resume()
                } else {
                    if let error = error {
                        print("[AuthManager] Sign In Failed.", error.localizedDescription)
                        continuation.resume(throwing: ErrorManager.authError(error))
                    } else {
                        print("[AuthManager] Sign In Failed with no error msg.")
                        continuation.resume(throwing: AuthErrorCode.internalError)
                    }
                }
            }
            
        }
    }
    
    /// Sign up by FireAuth
    ///
    /// If Failed to sign in, this method will print debug message.
    ///
    /// # Handle Error:
    /// Error will be sended to closure. Type is AuthErrorCode?. defined at FirebaseAuth.
    /// - Parameters:
    ///     - email: Email want to sign up with
    ///     - password: Password want to sign up with
    /// - Returns: Return true when signin succesfully, return false when sigin failed.
    public func signUp(email: String, password: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if result != nil {
                    print("[AuthManager] Sign Up Successfully.")
                    continuation.resume()
                } else {
                    if let error = error {
                        print("[AuthManager] Sign Up Failed.", error.localizedDescription)
                        continuation.resume(throwing: ErrorManager.authError(error))
                    } else {
                        print("[AuthManager] Sign Up Failed with no error msg.")
                        continuation.resume(throwing: AuthErrorCode.internalError)
                    }
                }
            }
        }
    }
    public func signOut() -> Bool {
        do {
            try Auth.auth().signOut()
            return true
        } catch (let error) {
            print("[AuthManager] Failed to sign out.", error.localizedDescription)
            return false
        }
    }
    /// Delete account in FirebaseAuth. User needs to login.
    ///
    /// - Parameters:
    ///     - completion: this function will send error to completion. by AuthErrorCode?
    public func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthErrorCode.userNotFound
        }
        
        let _: Void = try await withCheckedThrowingContinuation { continuation in
            user.delete { error in
                if let error = error {
                    print("[AuthManager] Failed to delete account.", error.localizedDescription)
                    continuation.resume(throwing: ErrorManager.authError(error))
                } else {
                    print("[AuthManager] Successfully delete account.")
                    continuation.resume()
                }
            }
        }
    }
    /// Updating user display name.
    ///
    /// - Parameters:
    ///     - displayName: String what you want to change.
    ///     - completion: Error will be send to this closure.
    public func updateProfileDisplayName(_ displayName: String) async throws {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = displayName
        let _: Void = try await withCheckedThrowingContinuation { continuation in
            changeRequest?.commitChanges { error in
                if let error = error {
                    print("[AuthManager] Failed to update display name.", error.localizedDescription)
                    continuation.resume(throwing: ErrorManager.authError(error))
                } else {
                    print("[AuthManager] Successfully updated display name.")
                    continuation.resume()
                }
            }
        }
        try await self.reloadUserInfo()
    }
    
    /// Change User Password
    public func updatePassword(_ password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthErrorCode.userNotFound
        }
        
        let _: Void = try await withCheckedThrowingContinuation { continuation in
            user.updatePassword(to: password) { error in
                if let error = error {
                    print("[AuthManager] Failed to update email.", error.localizedDescription)
                    continuation.resume(throwing: ErrorManager.authError(error))
                } else {
                    print("[AuthManager] Successfully updated email.")
                    continuation.resume()
                }
            }
        }
    }
    
    /// reload User info.
    ///
    /// Thiis function fetch user info to FirebaseAuth server. and reloading self.userInfo.
    private func reloadUserInfo() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthErrorCode.userNotFound
        }
        
        let _: Void = try await withCheckedThrowingContinuation { continuation in
            user.reload { error in
                if let error = error {
                    print("[AuthManager] Failed to reload user info.")
                    continuation.resume(throwing: ErrorManager.authError(error))
                } else {
                    print("[AuthManager] Successfully reload user info.")
                    self.userInfo = UserInfo(email: user.email, uid: user.uid, displayName: user.displayName)
                    continuation.resume()
                }
            }
        }
    }
    
    init() {
        // Make Auth handler
        // This handler manage user data like delegate.
        handle = Auth.auth().addStateDidChangeListener { auth, user in
            self.isUserLogin = user != nil
            self.userInfo = UserInfo(email: user?.email, uid: user?.uid, displayName: user?.displayName)
        }
    }
}
