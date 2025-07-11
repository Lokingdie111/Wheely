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
    
    var handle: AuthStateDidChangeListenerHandle?
    
    /// Sign in by fireAuth
    ///
    /// If failed to sign in, this method will print debug message.
    /// - Parameters:
    ///     - email: User email
    ///     - password: User password
    /// - Returns: Return true when signin succesfully, return false when sigin failed.
    public func signIn(email: String, password: String) async -> Bool {
        let result = await withCheckedContinuation { continuation in
            
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if result != nil {
                    continuation.resume(returning: true)
                } else {
                    if let error = error {
                        print("[AuthManager] Sign In Failed.", error.localizedDescription)
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
    /// - Parameters:
    ///     - email: Email want to sign up with
    ///     - password: Password want to sign up with
    /// - Returns: Return true when signin succesfully, return false when sigin failed.
    public func signUp(email: String, password: String) async -> Bool {
        let signUpResult = await withCheckedContinuation { continuation in
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if result != nil {
                    continuation.resume(returning: true)
                } else {
                    if let error = error {
                        print("[AuthManager] Sign Up Failed.", error.localizedDescription)
                    } else {
                        print("[AuthManager] Sing Up Failed with no error msg.")
                    }
                    continuation.resume(returning: false)
                }
            }
        }
        return signUpResult
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
