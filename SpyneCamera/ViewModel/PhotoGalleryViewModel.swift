//
//  PhotoGalleryViewModel.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 14/11/24.
//

import Foundation
import RealmSwift

@Observable class PhotoGalleryViewModel {
    private let photoManager: PhotoManager = PhotoManager()
    private(set) var errorMessage: String = ""
    var showErrorAlert: Bool = false
    init() {
        print("init: PhotoGalleryViewModel")
    }
    
    deinit {
        print("deinit: PhotoGalleryViewModel")
    }
    
    @MainActor
    func upload(_ photos: Results<Photo>) async {
        do {
            try await photoManager.requestUploadToCloud(photos: photos)
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
