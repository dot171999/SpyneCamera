//
//  ContentView.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 09/11/24.
//

import SwiftUI
import RealmSwift

struct HomeScreen: View {
    @State var toastManager: ToastManagerProtocol = ToastManager.shared
    @State private var selectedTab: Tab = .photoGallery
    
    var body: some View {
        VStack(spacing: 0) {
            HomeTabBarView(selectedTab: $selectedTab)
            
            TabView(selection: $selectedTab) {
                PhotoGalleryView()
                    .tag(Tab.photoGallery)
                CameraView() {
                    selectedTab = .photoGallery
                }
                .tag(Tab.camera)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .ignoresSafeArea(.container, edges: .bottom)
        #if targetEnvironment(macCatalyst)
        .frame(width: 450)
        #endif
        .toast(toastManager)
    }
}

#Preview {
    let congif = Realm.Configuration(inMemoryIdentifier:  UUID().uuidString)
    return HomeScreen()
        .environment(\.realmConfiguration, congif)
}
