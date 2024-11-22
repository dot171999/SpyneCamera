//
//  HomeTabBarView.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 10/11/24.
//

import SwiftUI

struct HomeTabBarView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding private(set) var selectedTab: Tab
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.rawValue) { tab in
                VStack {
                    Text(tab.rawValue)
                    Rectangle()
                        .frame(height: 3)
                        .foregroundStyle(selectedTab == tab ? Color("TabSelector") : .clear)
                        .opacity(selectedTab == tab ? 1 : 0)
                        .matchedGeometryEffect(id: "ActiveTab", in: animation, isSource: selectedTab == tab)

                }
                .contentShape(Rectangle())
                .animation(.bouncy, value: selectedTab)
                .onTapGesture {
                    withAnimation {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.top)
        .padding(.bottom, 2)
        .background( Color(colorScheme == .dark ? .black : .white))
    }
}

#Preview {
    HomeTabBarView(selectedTab: .constant(Tab.photoGallery))
}
