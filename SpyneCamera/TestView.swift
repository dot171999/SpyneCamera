//
//  TestView.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 10/11/24.
//

import SwiftUI

struct TestView: View {
    var body: some View {
        ZStack {
            Color.red
                .ignoresSafeArea()
            VStack {
                Rectangle()
                    .foregroundColor(.blue)
                    .ignoresSafeArea()
            }
            
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            .border(Color.red)
            //.padding()
        }
        
    }
}

#Preview {
    TestView()
}
