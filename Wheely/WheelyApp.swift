//
//  WheelyApp.swift
//  Wheely
//
//  Created by 민현규 on 7/11/25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

// TODO: 이왕하는거 제대로.
@main
struct WheelyApp: App {
    @StateObject var authManager = AuthManager()
    @StateObject var tabViewController = TabViewController()
    // FireBase prepare
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(authManager)
                .environmentObject(tabViewController)
        }
    }
    
}
