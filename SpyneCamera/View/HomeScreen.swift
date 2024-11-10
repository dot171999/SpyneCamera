//
//  ContentView.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 09/11/24.
//

import SwiftUI

struct HomeScreen: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedTab: Tab = .galary
    
    private enum Tab: String {
        case galary = "Photo Galary"
        case camera = "Camera"
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            PhotoGalleryView()
                .tag(Tab.galary)
                .ignoresSafeArea(.container, edges: .bottom)
            CameraView()
                .tag(Tab.camera)
                
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea(.container, edges: .bottom)
    }
}

#Preview {
    HomeScreen()
}
