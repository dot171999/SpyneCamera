//
//  PhotoGalleryViewModel.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 14/11/24.
//

import Foundation
import RealmSwift

@Observable class PhotoGalleryViewModel {
    private let photoManager: PhotoManager
    private let toastManager: ToastManager
    private(set) var errorMessage: String = ""
    var showErrorAlert: Bool = false
    
    init(toastManager: ToastManager = ToastManager.shared, photoManager: PhotoManager = PhotoManager()) {
        self.photoManager = photoManager
        self.toastManager =  toastManager
        print("init: PhotoGalleryViewModel")
    }
    
    deinit {
        print("deinit: PhotoGalleryViewModel")
    }
    
    @MainActor
    func upload(_ photos: Results<Photo>) async {
        do {
            let photosNotUploaded = photos.where { photo in
                !photo.isUploaded
            }
            guard !photosNotUploaded.isEmpty else { return }
            toastManager.show(message: "Uploading photos.")
            try await photoManager.requestUploadToCloud(photos: photos)
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
