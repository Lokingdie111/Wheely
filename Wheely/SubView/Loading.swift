//
//  Loading.swift
//  Wheely
//
//  Created by 민현규 on 7/19/25.
//

import SwiftUI

struct Loading: View {
    @State private var isLoading: Bool = false
    var speed: Double = 0.5
    
    var body: some View {
        Image(systemName: "circle.hexagonpath")
            .resizable()
            .scaledToFit()
            .foregroundStyle(Color.electricIndigo)
            .rotationEffect(Angle(degrees: isLoading ? 360 : 0), anchor: .center)
            .animation(.linear(duration: 1 / speed).repeatForever(autoreverses: false), value: isLoading)
            .onAppear {
                isLoading = true
            }
            .onDisappear {
                isLoading = false
            }
    }
}

#Preview {
    Loading(speed: 0.5)
        .frame(width: 50, height: 50)
}
