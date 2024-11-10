//
//  TestView.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 10/11/24.
//

import SwiftUI

struct TestView: View {
    var body: some View {
        VStack {
            Rectangle()
                .foregroundColor(.blue)
        }
        
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .border(Color.red)
        
        
    }
}

#Preview {
    TestView()
}
