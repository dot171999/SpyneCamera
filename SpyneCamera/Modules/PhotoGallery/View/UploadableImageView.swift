//
//  UploadableImageView.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 11/11/24.
//

import SwiftUI

struct UploadableImageView: View {
    @Environment(\.colorScheme) private var colorScheme
    private let progress: Float?
    private let photo: Photo
    
    init(progress: Float?, photo: Photo) {
        self.progress = progress
        self.photo = photo
    }
    
    var body: some View {
        Rectangle()
            .aspectRatio(1, contentMode: .fit)
            .overlay(alignment: .center) {
                #if targetEnvironment(simulator)
                Image(["Image", "Image1"].randomElement()!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                #else
                if let image = UIImage(contentsOfFile: photo.urlPathString) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
                #endif
            }
            .overlay(alignment: .bottom) {
                if let progress {
                    ProgressView(value: progress)
                        .scaleEffect(y: 4)
                }
            }
            .overlay(alignment: .topTrailing) {
                Circle()
                    .frame(width: 15)
                    .foregroundStyle(.red)
                    .background(Circle()
                        .stroke(Color.white ,lineWidth: 4))
                    .padding()
                    .shadow(color: .black, radius: 20)
                    .opacity(photo.isUploaded ? 0 : 1)
            }
            .clipped()
    }
}

#Preview {
    UploadableImageView(progress: 0.5, photo: Photo())
}
