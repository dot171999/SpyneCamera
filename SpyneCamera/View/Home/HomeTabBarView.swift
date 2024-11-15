//
//  HomeTabBarView.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 10/11/24.
//

import SwiftUI

struct HomeTabBarView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding private(set) var selectedTab: HomeScreen.Tab
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(HomeScreen.Tab.allCases, id: \.rawValue) { tab in
                VStack {
                    Text(tab.rawValue)
                    if selectedTab == tab {
                        Rectangle()
                            .frame(height: 3)
                            .foregroundStyle(Color("TabSelector"))
                            .matchedGeometryEffect(id: "ActiveTab", in: animation)
                    } else {
                        Rectangle()
                            .frame(height: 3)
                            .opacity(0)
                    }
                }
                .contentShape(Rectangle())
                .animation(.snappy, value: selectedTab)
                .onTapGesture {
                    selectedTab = tab
                }
            }
        }
        .padding(.top)
        .padding(.bottom, 2)
        .background( Color(colorScheme == .dark ? .black : .white))
    }
}

#Preview {
    HomeTabBarView(selectedTab: .constant(HomeScreen.Tab.photoGallery))
}
