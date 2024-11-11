//
//  ContentView.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 09/11/24.
//

import SwiftUI

struct HomeScreen: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedTab: Tab = .photoGalary
    
    enum Tab: String, CaseIterable {
        case photoGalary = "Photo Galary"
        case camera = "Camera"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HomeTabBarView(selectedTab: $selectedTab)
            
            TabView(selection: $selectedTab) {
                PhotoGalleryView()
                    .tag(Tab.photoGalary)
                CameraView()
                    .tag(Tab.camera)
                    
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .frame(width: getMacFrameWidth())
    }
    
    private func getMacFrameWidth() -> CGFloat {
#if targetEnvironment(macCatalyst)
        return 450 // Set specific width for macOS
#else
        return UIScreen.main.bounds.width  // Default width for iPhone/iPad
#endif
    }
}

#Preview {
    HomeScreen()
}
