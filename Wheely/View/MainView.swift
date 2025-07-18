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
                Image(systemName: "house")
                Text("Home")
            }
            
            Tab(value: TabSelection.wheels) {
                WheelsView()
            } label: {
                Image(systemName: "bicycle")
                Text("Wheels")
            }
            
            Tab(value: TabSelection.profile) {
                ProfileView()
            } label: {
                Image(systemName: "person")
                Text("Profile")
            }
            
            Tab(value: TabSelection.settings) {
                SettingsView()
            } label: {
                Image(systemName: "gear")
                Text("Settings")
            }
            
            Tab(value: TabSelection.settings) {
                ManualView()
            } label: {
                Image(systemName: "text.document")
                Text("Manual")
            }
        }
    }
}

#Preview {
    MainView()
        .environmentObject(TabViewController())
}
