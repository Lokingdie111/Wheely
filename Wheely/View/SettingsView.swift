//
//  SettingsView.swift
//  Wheely
//
//  Created by 민현규 on 7/12/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var tabViewController: TabViewController
    var body: some View {
        Text("SettingsView")
        Button("Movew to home") {
            tabViewController.selectedTab = .home
        }
    }
}

#Preview {
    SettingsView()
}
