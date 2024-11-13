//
//  PhotoGalleryView.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 10/11/24.
//

import SwiftUI
import RealmSwift

@Observable class PhotoGalleryViewModel {
    let photoService: PhotoService = PhotoService()
    init() {
        print("init: PhotoGalleryViewModel")
    }
    
    deinit {
        print("deinit: PhotoGalleryViewModel")
    }
}

struct PhotoGalleryView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var viewModel = PhotoGalleryViewModel()
    @State private var presentSheet: Photo? = nil
    @ObservedResults(Photo.self, sortDescriptor: SortDescriptor(keyPath: "captureDate", ascending: false)) private var photos
    
    private let lazyVGridRowSpacing: CGFloat = 2
    private let lazyVGridColumns: [GridItem] = [GridItem(spacing: 2), GridItem()]
    
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: lazyVGridColumns, spacing: lazyVGridRowSpacing) {
                ForEach(photos, id: \.self) { photo in
                    let currentUploadTask = viewModel.photoService.uploadingTaskProgress
                    
                    if photo.name == currentUploadTask.taskID {
                        let _ = print(currentUploadTask)
                    }
                    UploadableImageView(progress: photo.name == currentUploadTask.taskID ? currentUploadTask.progress : nil, photo: photo)
                        .onTapGesture {
                            presentSheet = photo
                        }
                }
                #if targetEnvironment(simulator)
                ForEach(0..<20, id: \.self) { photo in
                    UploadableImageView(photo: Photo())
                        .onTapGesture {
                            presentSheet = Photo()
                        }
                }
                #endif
            }
        }
        .sheet(item: $presentSheet, content: { photo in
            ExpandedPhotoView(photo: photo)
        })
        .onAppear() {
            for photo in photos {
                viewModel.photoService.requestUploadToCloud(photo: photo)
            }
        }
    }
}

#Preview {
    let congif = Realm.Configuration(inMemoryIdentifier:  "YES")
    return PhotoGalleryView()
        .environment(\.realmConfiguration, congif)
}
