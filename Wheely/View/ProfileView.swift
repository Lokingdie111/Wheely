//
//  ProfileView.swift
//  Wheely
//
//  Created by 민현규 on 7/18/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    
    @State var email: String = ""
    @State var password: String = ""
    
    var body: some View {
        if authManager.isUserLogin {
            
        } else {
            VStack {
                Text("Wheely")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Login for using wheely.")
                LoginComponent(email: $email, password: $password)
                    .frame(maxWidth: 320)
                HStack {
                    Text("If you don't have an account,")
                    Button{
                        
                    } label: {
                        Text("Sign-up")
                    }
                    Text("here")
                }
                .font(.caption)
            }
        }
    }
}

/// 이메일과 비밀번호를 입력받습니다.
struct LoginComponent: View {
    @Binding var email: String
    @Binding var password: String
    
    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .padding(5)
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.black, lineWidth: 1)
                }
            SecureField("Password", text: $password)
                .padding(5)
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.black, lineWidth: 1)
                }

        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthManager())
}
