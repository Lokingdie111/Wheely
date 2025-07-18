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
                    await dataManager?.makeField("test3")
                    await dataManager?.addData("test3", data: FirestoreData(date: .now, values: [1,1,1,1,1]))
                }
            }
            Button("GET") {
                Task{
                    let result = await dataManager?.get()
                    print(String(describing: result))
                }
            }
            Button("UPDATE") {
                Task {
                    await dataManager?.updateFieldName("test3", "ADMIN")
                }
            }
            Button("Delete") {
                Task{
                    await dataManager?.removeField("test3")
                }
            }
        }
        .padding()
        .onAppear {
            Task {
                self.dataManager = await DataManager.create(uid: "ADMIN2")
                print("Manager Created.")
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
}
