//
//  HomeView.swift
//  Wheely
//
//  Created by 민현규 on 7/12/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var tabViewController: TabViewController
    var body: some View {
        Text("Home View")
        Button("Move to Settings") {
            tabViewController.selectedTab = .settings
        }
    }
}

#Preview {
    HomeView()
}
