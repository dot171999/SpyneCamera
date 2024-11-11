//
//  PhotoGalleryView.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 10/11/24.
//

import SwiftUI
import RealmSwift

struct PhotoGalleryView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State var presentSheet: Photo? = nil
    @ObservedResults(Photo.self) var photos
    
    private let lazyVGridRowSpacing: CGFloat = 2
    private let lazyVGridColumns: [GridItem] = [GridItem(spacing: 2), GridItem()]
    
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: lazyVGridColumns, spacing: lazyVGridRowSpacing) {
                ForEach(photos, id: \.self) { photo in
                    UploadableImageView(progress: 0.5, uiImage: UIImage(contentsOfFile: photo.urlPath))
                        .onTapGesture {
                            presentSheet = photo
                        }
                }
            }
        }
        .sheet(item: $presentSheet, content: { photo in
            ExpandedPhotoView(photo: photo)
        })
    }
}

#Preview {
    PhotoGalleryView()
}
