//
//  TabViewController.swift
//  Wheely
//
//  Created by 민현규 on 7/12/25.
//

import Foundation

enum TabSelection {
    case home
    case settings
    case profile
    case wheels
}

@MainActor
class TabViewController: ObservableObject {
    @Published var selectedTab: TabSelection = .home
    
    public func changeSelection(_ selection: TabSelection) {
        self.selectedTab = selection
    }
}
