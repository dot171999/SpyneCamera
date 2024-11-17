//
//  ExpandedPhotoView.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 11/11/24.
//

import SwiftUI

struct ExpandedPhotoView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    private let photo: Photo
    
    init(photo: Photo) {
        self.photo = photo
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .foregroundStyle(.black)
                .overlay {
                    if let image  = UIImage(contentsOfFile: photo.urlPathString) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                    #if targetEnvironment(simulator)
                    if let image  = UIImage(named: "Image") {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                    #endif
                }
            VStack(alignment: .leading) {
                Text("Name: \(photo.name)")
                Text("Date: \(photo.captureDate)").lineLimit(1)
                Text("Upload Status: \(photo.isUploaded)")
                Text("Storage location: \(photo.urlPathString)")
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.gray.opacity(0.2))
        }
        .overlay(alignment: .topLeading, content: {
            Button(action: {
                dismiss()
            }, label: {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .shadow(color: .black, radius: 5, x: 0, y: 1)
            })
            .padding()
        })
    }
}

#Preview {
    ExpandedPhotoView(photo: Photo())
}
