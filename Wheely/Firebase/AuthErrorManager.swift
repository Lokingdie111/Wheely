//
//  AuthErrorManager.swift
//  Wheely
//
//  Created by 민현규 on 7/11/25.
//

import Foundation
import FirebaseAuth

class AuthErrorManager {
    public static func checkError(_ error: Error) -> AuthErrorCode {
        if let error = error as NSError? {
            let authError = AuthErrorCode(rawValue: error.code)
            if let authError = authError {
                return authError
            } else {
                return .internalError
            }
        } else {
            print("[AuthErrorManager] Unknown Error")
            return .internalError
        }
    }
}
