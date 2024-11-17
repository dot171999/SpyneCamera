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
                if let image = UIImage(named: "Image1") {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
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
                    HStack {
                        Button {
                            
                        } label: {
                            Image(systemName: "play.fill")
                        }
                        ProgressView(value: progress)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .background(colorScheme == .dark ? .white : .black)
                    .clipShape(.rect(cornerRadius: 5))
                    .padding()
                }
            }
            .overlay(alignment: .topTrailing) {
                Circle()
                    .frame(width: 20)
                    .foregroundStyle(photo.isUploaded ? .green : .red)
                    .background(Circle()
                        .stroke(Color.white ,lineWidth: 4))
                    .padding()
                    .shadow(color: .black, radius: 20)
                    
            }
            .clipped()
    }
}

#Preview {
    UploadableImageView(progress: 0, photo: Photo())
}
