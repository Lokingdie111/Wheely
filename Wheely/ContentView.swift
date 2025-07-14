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
                let firestoremanager = FirestoreManager(uid: "ADMIN1")
                Task {
                    await firestoremanager.makeField("test1")
                    await firestoremanager.addData("test1", data: FirestoreData(date: .now, values: [1,2,3,4,5,6,7,8,9,10,11,12]))
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
