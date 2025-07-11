//
//  ContentView.swift
//  Wheely
//
//  Created by 민현규 on 7/11/25.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var authManager: AuthManager
    @State var errorText: String = ""
    @State var email: String = ""
    @State var password: String = ""
    @State var displayName: String = ""
    
    var body: some View {
        VStack {
            Text(authManager.userInfo?.displayName ?? "Hello, World!")
            Text(authManager.isUserLogin ? "Logged in" : "Logged out")
            Text(errorText)
            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
            TextField("Password", text: $password)
            TextField("Display Name", text: $displayName)
            Button("Sign-up") {
                Task {
                    let result = await authManager.signUp(email: email, password: password) { error in
                        if let error = error {
                            if error == .emailAlreadyInUse {
                                errorText = "Email is already in use."
                            } else if error == .invalidEmail {
                                errorText = "Invalid email format."
                            }
                        }
                    }
                    if result == true {
                        print("Success to sign up")
                        let displayResult = await authManager.updateProfileDisplayName(displayName) { error in
                            if let error = error {
                                print("Error occurred: \(error)")
                            }
                        }
                        if displayResult == true {
                            print("Success to set display name")
                        } else {
                            print("Failed to set display name")
                        }
                    }
                    
                }
            }
            Button("Sign-out") {
                print(authManager.signOut())
            }
            Button("delete") {
                Task {
                    let result = await authManager.deleteAccount { error in
                        if let error = error {
                            if error == .userNotFound {
                            }
                        }
                    }
                }
            }
            Button("Update displayName") {
                Task {
                    await authManager.updateProfileDisplayName(displayName) { error in
                        if let error = error {
                            print("ERROR")
                        }
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
