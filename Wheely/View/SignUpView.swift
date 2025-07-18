//
//  SignUpView.swift
//  Wheely
//
//  Created by 민현규 on 7/18/25.
//

import SwiftUI
import ExamineKit

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    
    @State var email: String = ""
    @State var password: String = ""
    @State var confirmPassword: String = ""
    @State var displayName: String = ""
    
    @State var alertMessage: String = ""
    @State var showAlert: Bool = false
    
    var body: some View {
        
        VStack {
            TextField("Email*", text: $email)
                .padding(5)
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.black, lineWidth: 1)
                }
            
            SecureField("Password*", text: $password)
                .padding(5)
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.black, lineWidth: 1)
                }
            
            SecureField("Confirm password*", text: $confirmPassword)
                .padding(5)
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.black, lineWidth: 1)
                }
            
            TextField("Display name*", text: $displayName)
                .padding(5)
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.black, lineWidth: 1)
                }
        }
        .frame(maxWidth: 350)
        Button("Confirm") {
            Task{
                let success = await confirm()
                if success {
                    alertMessage = "Successfully signed up at Wheely!"
                    showAlert = true
                    dismiss()
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertMessage))
        }
    }
    
    func confirm() async -> Bool {
        return true
    }
}

#Preview {
    SignUpView()
}
