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
    
    @State var dataManager: DataManager?
    
    var body: some View {
        VStack {
            Button("CLICK") {
                Task {
                    let result = await dataManager?.get("test")
                    await dataManager?.updateData("test", data: FirestoreData(date: result![0].date, values: [1,2,3,4,5]))
                }
            }
            Button("GET") {
                Task{
                    let result = await dataManager?.get()
                    print(String(describing: result))
                }
            }
        }
        .padding()
        .onAppear {
            Task {
                self.dataManager = await DataManager.create(uid: "ADMIN1")
                print("Manager Created.")
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
}
