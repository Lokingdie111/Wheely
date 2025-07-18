//
//  HomeView.swift
//  Wheely
//
//  Created by 민현규 on 7/12/25.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var tabViewController: TabViewController
    
    var body: some View {
        TabView(selection: $tabViewController.selectedTab) {
            Tab(value: TabSelection.home) {
                HomeView()
            } label: {
                Text("Home")
            }

            Tab(value: TabSelection.settings) {
                SettingsView()
            } label: {
                Text("Settings")
            }
        }
    }
}

#Preview {
    MainView()
}
