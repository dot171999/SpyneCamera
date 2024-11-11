//
//  ExpandedPhotoView.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 11/11/24.
//

import SwiftUI

struct ExpandedPhotoView: View {
    @Environment(\.dismiss) private var dismiss
    let photo: Photo
    var body: some View {
        VStack(alignment: .leading) {
            Rectangle()
                .foregroundStyle(.black)
                .overlay {
                    if let image  = UIImage(contentsOfFile: photo.urlPath) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                }
                
            VStack(alignment: .leading) {
                Text("Name: \(photo.nameWithExtension)")
                Text("Date: \(photo.captureDate)")
                Text("Upload Status: \(photo.isUploaded)")
                Text("Storage location: \(photo.urlPath)")
            }
            .padding()
        }
        .overlay(alignment: .topLeading, content: {
            Button(action: {
                dismiss()
            }, label: {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
            })
            .padding()
        })
    }
}

#Preview {
    ExpandedPhotoView(photo: Photo())
}
