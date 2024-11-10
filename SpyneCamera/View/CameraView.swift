//
//  CameraView.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 10/11/24.
//

import SwiftUI

struct CameraView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
            ZStack {
                HStack {
                    GalaryPreview(image: nil)
                    Spacer()
                }
                ShutterButton {
                    
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    func GalaryPreview(image: UIImage?) -> some View {
        if let image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .clipShape(.rect(cornerRadius: 10))
            
        } else {
            Rectangle()
                .frame(width: 50, height: 50, alignment: .center)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .clipShape(.rect(cornerRadius: 10))
        }
    }
    
    @ViewBuilder
    func ShutterButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Circle()
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .frame(width: 70, height: 70, alignment: .center)
                .overlay(
                    Circle()
                        .stroke(colorScheme == .dark ? .black : .white, lineWidth: 2)
                        .frame(width: 58, height: 58, alignment: .center)
                )
        }
    }
}

#Preview {
    CameraView()
}
