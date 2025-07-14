//
//  AuthErrorManager.swift
//  Wheely
//
//  Created by 민현규 on 7/11/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class ErrorManager {
    public static func authError(_ error: Error) -> AuthErrorCode {
        if let error = error as NSError? {
            let authError = AuthErrorCode(rawValue: error.code)
            if let authError = authError {
                return authError
            } else {
                return .internalError
            }
        } else {
            print("[ErrorManager] Unknown Error")
            return .internalError
        }
    }
    public static func firestoreError(_ error: Error) -> FirestoreError {
        let nsError = error as NSError
        let result = FirestoreErrorCode.Code(rawValue: nsError.code)
        
        if let result = result {
            return FirestoreError.firebase(code: result)
        } else {
            return FirestoreError.firebase(code: .internal)
        }
    }
}
