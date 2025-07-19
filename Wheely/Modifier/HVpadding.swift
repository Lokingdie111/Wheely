//
//  HVpadding.swift
//  Wheely
//
//  Created by 민현규 on 7/19/25.
//

import SwiftUI

struct HVpadding: ViewModifier {
    var horizontal: CGFloat
    var vertical: CGFloat
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, horizontal)
            .padding(.vertical, vertical)
    }
}

extension View {
    /// horizontal, vertical
    func hvPadding(_ horizontal: CGFloat = 8, _ vertical: CGFloat = 8) -> some View {
        modifier(HVpadding(horizontal: horizontal, vertical: vertical))
    }
}
