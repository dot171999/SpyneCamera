//
//  PhotoGalleryViewModel.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 14/11/24.
//

import Foundation
import RealmSwift

@Observable class PhotoGalleryViewModel {
    private let photoManager: PhotoManagerProtocol
    private let toastManager: ToastManagerProtocol
    
    private(set) var errorMessage: String = ""
    var showErrorAlert: Bool = false
    
    private(set) var isUploading: Bool = false
    private var numberOfPhotosSetToUpload: Int = 0
    var totalUploadProgress: Float {
        let pendingUploadCount = photoManager.pendingUploadRequests.count
        guard pendingUploadCount != 0 else { return 1 }
        let uploadedCount: Float = Float(numberOfPhotosSetToUpload - pendingUploadCount)
        return uploadedCount / Float(numberOfPhotosSetToUpload)
    }
    
    init(toastManager: ToastManagerProtocol = ToastManager.shared,
         photoManager: PhotoManagerProtocol = PhotoManager()
    ) {
        self.photoManager = photoManager
        self.toastManager =  toastManager
    }
    
    @MainActor
    func upload(_ photos: Results<Photo>) async {
        defer {
            isUploading = false
        }
        do {
            let photosNotUploaded = photos.where { photo in
                !photo.isUploaded
            }
            guard !photosNotUploaded.isEmpty else { return }
            toastManager.show(message: "Uploading photos.")
            numberOfPhotosSetToUpload = photosNotUploaded.count
            print("009 to upload", numberOfPhotosSetToUpload)
            isUploading = true
            try await photoManager.upload(photos: photosNotUploaded)
            toastManager.show(message: "Photos uploaded.")
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }
    
    func progress(for photo: Photo) -> Float? {
        let currentUploadTask = photoManager.uploadingTaskProgress
        return photo.name == currentUploadTask.taskID ? currentUploadTask.progress : nil
    }
}
