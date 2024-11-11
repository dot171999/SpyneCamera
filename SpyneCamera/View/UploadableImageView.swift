//
//  UploadableImageView.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 11/11/24.
//

import SwiftUI

struct UploadableImageView: View {
    @Environment(\.colorScheme) private var colorScheme
    let progress: Float
    let uiImage: UIImage?
    
    var body: some View {
        Rectangle()
            .aspectRatio(1, contentMode: .fit)
            .overlay(alignment: .center) {
                if let image = uiImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }
            .overlay(alignment: .bottom) {
                HStack {
                    Button {
                        
                    } label: {
                        Image(systemName: "play.fill")
                    }
                    ProgressView(value: progress)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(colorScheme == .dark ? .white : .black)
            }
            .clipped()
    }
}

#Preview {
    UploadableImageView(progress: 0.8, uiImage: UIImage(named: "Image"))
}
