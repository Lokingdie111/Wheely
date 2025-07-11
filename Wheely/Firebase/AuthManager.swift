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
    public func signIn(email: String, password: String, completion: @escaping (AuthErrorCode?) -> Void) async -> Bool {
        let result = await withCheckedContinuation { continuation in
            
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if result != nil {
                    print("[AuthManager] Sign In Successfully.")
                    continuation.resume(returning: true)
                } else {
                    if let error = error {
                        print("[AuthManager] Sign In Failed.", error.localizedDescription)
                        completion(AuthErrorManager.checkError(error))
                    } else {
                        print("[AuthManager] Sign In Failed with no error msg.")
                    }
                    continuation.resume(returning: false)
                }
            }
            
        }
        
        return result
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
    public func signUp(email: String, password: String, completion: @escaping (AuthErrorCode?) -> Void) async -> Bool {
        let signUpResult = await withCheckedContinuation { continuation in
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if result != nil {
                    print("[AuthManager] Sign Up Successfully.")
                    continuation.resume(returning: true)
                } else {
                    if let error = error {
                        print("[AuthManager] Sign Up Failed.", error.localizedDescription)
                        completion(AuthErrorManager.checkError(error))
                    } else {
                        print("[AuthManager] Sign Up Failed with no error msg.")
                    }
                    continuation.resume(returning: false)
                }
            }
        }
        return signUpResult
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
    public func deleteAccount(completion: @escaping (AuthErrorCode?) -> Void) async -> Bool {
        let user = Auth.auth().currentUser
        
        if let user = user {
            let result = await withCheckedContinuation { continuation in
                user.delete { error in
                    if let error = error {
                        print("[AuthManager] Failed to delete account.", error.localizedDescription)
                        completion(AuthErrorManager.checkError(error))
                        continuation.resume(returning: false)
                    } else {
                        print("[AuthManager] Successfully delete account.")
                        continuation.resume(returning: true)
                    }
                }
            }
            return result
        } else {
            print("[AuthManager] Failed to delete account. User not login.")
            return false
        }
    }
    /// Updating user display name.
    ///
    /// - Parameters:
    ///     - displayName: String what you want to change.
    ///     - completion: Error will be send to this closure.
    public func updateProfileDisplayName(_ displayName: String, completion: @escaping (AuthErrorCode?) -> Void) async -> Bool {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = displayName
        let result = await withCheckedContinuation { continuation in
            changeRequest?.commitChanges { error in
                if let error = error {
                    print("[AuthManager] Failed to update display name.", error.localizedDescription)
                    completion(AuthErrorManager.checkError(error))
                    continuation.resume(returning: false)
                } else {
                    print("[AuthManager] Successfully updated display name.")
                    continuation.resume(returning: true)
                }
            }
        }
        if result == true {
            _ = await self.reloadUserInfo { error in
                if let error = error {
                    print("[AuthManager] Failed to reload user info after update display name.")
                    completion(error)
                }
            }
        }
        return result
    }
    /// reload User info
    ///
    /// Thiis function fetch user info to FirebaseAuth server. and reloading self.userInfo.
    private func reloadUserInfo(completion: @escaping (AuthErrorCode?) -> Void) async -> Bool{
        guard let user = Auth.auth().currentUser else {
            return false
        }
        
        let result = await withCheckedContinuation { continuation in
            user.reload { error in
                if let error = error {
                    print("[AuthManager] Failed to reload user info.")
                    completion(AuthErrorManager.checkError(error))
                    continuation.resume(returning: false)
                } else {
                    print("[AuthManager] Successfully reload user info.")
                    self.userInfo = UserInfo(email: user.email, uid: user.uid, displayName: user.displayName)
                    continuation.resume(returning: true)
                }
            }
        }
        return result
        
    }
    
    init() {
        // Make Auth handler
        // This handler manage user data like delegate.
        handle = Auth.auth().addStateDidChangeListener { auth, user in
            self.isUserLogin = user != nil
            self.userInfo = UserInfo(email: user?.email, uid: user?.uid, displayName: user?.displayName)
        }
    }
    
    deinit {
        // Remove Auth handler
        Auth.auth().removeStateDidChangeListener(handle!)
    }
}
