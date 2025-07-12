//
//  ContentView.swift
//  Wheely
//
//  Created by 민현규 on 7/11/25.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    
    @EnvironmentObject var authManager: AuthManager
    @State var errorText: String = ""
    @State var email: String = ""
    @State var password: String = ""
    @State var displayName: String = ""
    
    var body: some View {
        VStack {
            Text(TimeManager.convertToUTC())
            Text(TimeManager.convertToLocal())
            Text(authManager.userInfo?.displayName ?? "Hello, World!")
            Text(authManager.isUserLogin ? "Logged in" : "Logged out")
            Text(errorText)
            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
            TextField("Password", text: $password)
            TextField("Display Name", text: $displayName)
            Button("Sign-up") {
                Task {
                    do {
                        try await authManager.signUp(email: email, password: password)
                    } catch AuthErrorCode.emailAlreadyInUse {
                        print("Email already in used.")
                        self.errorText = "Email already in used."
                    } catch AuthErrorCode.internalError {
                        print("Interal Error caused.")
                        self.errorText = "Internal Error Caused."
                    } catch AuthErrorCode.weakPassword {
                        print("Weak password")
                        self.errorText = "Weak password"
                    }
                    
                    do {
                        try await authManager.updateProfileDisplayName(displayName)
                    } catch AuthErrorCode.userNotFound {
                        print("Must to login first")
                    }
                }
            }
            Button("Change Display Name") {
                Task {
                    do {
                        try await authManager.updateProfileDisplayName(displayName)
                    } catch {
                        print("ERROR")
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
}
