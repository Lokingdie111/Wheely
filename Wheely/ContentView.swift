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
            Button("CLICK") {
                let firestoremanager = FirestoreManager(uid: "ADMIN")
                Task {
                    let result = await firestoremanager.get()
                    print("\(String(describing: result))")
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
