//
//  PhotoManager.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 11/11/24.
//

import Foundation
import RealmSwift
import PhotosUI

protocol PhotoManagerProtocol {
    func savePhoto(_ uiImage: UIImage) throws
    @MainActor func upload(photos: Results<Photo>) async throws
    func allPhotos() -> Results<Photo>
    var uploadingTaskProgress: (taskID: String, progress: Float) { get }
}

@Observable class PhotoManager: NSObject, PhotoManagerProtocol {
    private let realmManager: RealmManagerProtocol
    private let fileManager: DataFileManagerProtocol
    private var networkService: NetworkProtocol
    
    // Acts like a serial queue
    private var pendingUploadRequests: [Photo] = []
    private var uploadInProgress: Bool = false
    private(set) var uploadingTaskProgress: (taskID: String, progress: Float) = ("empty", 0)
    
    init(realmManager: RealmManagerProtocol = RealmManager(),
         fileManager: DataFileManagerProtocol = DataFileManager(),
         networkService: NetworkProtocol = NetworkManager()
    ) {
        self.realmManager = realmManager
        self.fileManager = fileManager
        self.networkService = networkService
    }
   
    deinit {
        print("deinit: Photo Service")
    }
    
    func savePhoto(_ uiImage: UIImage) throws {
        let photoName = UUID().uuidString
        guard let jpegPhotoData = uiImage.jpegData(compressionQuality: 1.0) else {
            throw PhotoManagerError.convertingUIImageToJpegData
        }
        
        guard let photoFileUrl = fileManager.generatePathUrl(forFileName: photoName, fileExtension: "jpg", in: .documentDirectory) else {
            throw PhotoManagerError.generatingPathUrl
        }
        
        try fileManager.writeData(jpegPhotoData, atPath: photoFileUrl)
        
        try saveToRealm(url: photoFileUrl, name: photoName)
    }
    
    @MainActor func upload(photos: Results<Photo>) async throws {
        queuePhotosForUpload(photos)

        guard !uploadInProgress else { print("returning"); return }
        uploadInProgress = true
        
        defer {
            uploadInProgress = false
        }
        
        try await processNextPhotoUpload()
    }
    
     private func queuePhotosForUpload(_ photos: Results<Photo>) {
        for photo in photos {
            guard !photo.isUploaded else { break }
            guard !(pendingUploadRequests.contains { $0.name == photo.name }) else { break }
            pendingUploadRequests.append(photo)
        }
    }
    
    @MainActor private func processNextPhotoUpload() async throws {
        guard !pendingUploadRequests.isEmpty, let photo = pendingUploadRequests.first else { return }
        
        let photoDTO = PhotoDTO(from: photo)
        
        do {
            try await uploadToCloud(photoDTO)
        } catch {
            throw error
        }
        
        pendingUploadRequests.removeFirst()
        print("Pending uploads count: \(pendingUploadRequests.count)")
        
        // Recursive
        try await processNextPhotoUpload()
    }
    
    private func uploadToCloud(_ photo: PhotoDTO) async throws {
        let photoData: Data
        do {
            photoData = try Data(contentsOf: URL(filePath: photo.urlPathString))
        } catch {
            throw PhotoManagerError.loadingPhotoData
        }
    
        let url: URL = API.urlForEndpoint(.upload)
        let boundry: String = photo.name
        let bodyData: Data = UrlRequestBuilder.createHttpBody(mimeType: .jpgImage, fileName: photo.name, field: "image", data: photoData, boundary: boundry)
        let urlRequest: URLRequest = UrlRequestBuilder.buildRequest(url: url, method: .post, mimeType: .multiPart(boundary: boundry), body: bodyData)
        networkService.sessionDelegate = self
        let result = await networkService.uploadTask(with: urlRequest, taskID: photo.name)
        
        switch result {
        case .success(_):
            await MainActor.run { [weak self] in
                guard let photoObject: Photo = self?.realmManager.objectForKey(primaryKey: photo.name) else { return }
                try? self?.realmManager.update {
                    photoObject.isUploaded = true
                }
            }
        case .failure(let error):
            throw error
        }
    }
    
    @discardableResult
    private func saveToRealm(url: URL, name: String) throws -> Photo {
        let photo = Photo()
        photo.captureDate = Date()
        photo.name = name
        photo.urlPathString = url.path
        
        try realmManager.add(object: photo)
        return photo
    }
    
    func allPhotos() -> Results<Photo> {
        realmManager.readAll()
    }
}

extension PhotoManager: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        guard let taskID = task.taskDescription else { return }
        let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        if progress >= 1.0 {
            uploadingTaskProgress = ("", 0)
        } else {
            uploadingTaskProgress = (taskID, progress)
        }
        print("progress: ", totalBytesSent , totalBytesExpectedToSend)
    }
}
