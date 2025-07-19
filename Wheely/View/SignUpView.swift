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
    
    @State var allOK: Bool = true
    
    @State var loading: Bool = false
    
    var body: some View {
        ZStack {
            if loading {
                Loading()
                    .frame(width: 40, height: 40)
                    .shadow(radius: 5, y: 5)
            }
            VStack {
                Text("Sign Up to Wheely")
                    .font(.title)
                    .fontWeight(.bold)
                
                VStack {
                    TextField("Email*", text: $email)
                        .padding(5)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.black, lineWidth: 1)
                        }
                        .textInputAutocapitalization(.never)
                    HStack {
                        VStack(alignment: .leading) {
                            // TODO: 컨펌 눌렀을때 형식 확인한후에 이거 표시되게 할것.
                            if false {
                                Text("· Invaild email format.")
                                    .font(.footnote)
                                    .foregroundStyle(.red)
                            }
                            
                            Text("· This email will be used for sign in.")
                                .font(.footnote)
                        }
                        
                        
                        Spacer()
                    }
                    SecureField("Password*", text: $password)
                        .padding(5)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.black, lineWidth: 1)
                        }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            // TODO: 만약 조건이 만족되면 글자 색이 회색으로 바뀌도록 할것.
                            Text("· Minimum length is 8.")
                                .font(.footnote)
                            Text("· At least one uppercase character required.")
                                .font(.footnote)
                            Text("· At least one special character required.")
                                .font(.footnote)
                        }
                        Spacer()
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
                                .stroke(Color.raisinBlack, lineWidth: 1)
                        }
                        .textInputAutocapitalization(.never)
                    HStack {
                        VStack(alignment: .leading) {
                            Text("· This name will be displayed for you.")
                                .font(.footnote)
                            Text("· Max length is 10.")
                                .font(.footnote)
                        }
                        
                        Spacer()
                    }
                }
                .frame(maxWidth: 350)
                Rectangle()
                    .frame(maxHeight: 35)
                    .foregroundStyle(Color.clear)
                Button("Confirm") {
                    Task{
                        loading = true
                        let success = await confirm()
                        loading = false
                        if success {
                            alertMessage = "Successfully signed up at Wheely!"
                            showAlert = true
                            dismiss()
                        }
                    }
                }
                .foregroundStyle(allOK ? Color.electricIndigo : Color.mediumStateBlue)
                .disabled(!allOK)
                .hvPadding(3, 4)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(content: {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(allOK ? Color.electricIndigo : Color.mediumStateBlue, lineWidth: 1)
                    
                })
                .shadow(radius: 5, y: 2)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertMessage))
        }
    }
    
    func confirm() async -> Bool {
        // TODO: Make Sequence of check is OK
        try? await Task.sleep(nanoseconds: 1000 * 1000 * 1000)
        return true
    }
}

#Preview {
    SignUpView()
}
