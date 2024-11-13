//
//  PhotoService.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 11/11/24.
//

import Foundation
import RealmSwift
import PhotosUI

@Observable class PhotoService: NSObject {
    @ObservationIgnored private let realmManager: RealmManager = RealmManager()
    @ObservationIgnored lazy private var networkManager: NetworkService = { [unowned self] in
        NetworkService(session: URLSession(configuration: .default, delegate: self, delegateQueue: .main))
    }()
    
    // Acts like a serial queue
    @ObservationIgnored private var pendingUploadRequests: [Photo] = []
    @ObservationIgnored private var uploadInProgress: Bool = false
    private(set) var uploadingTaskProgress: (taskID: String, progress: Float) = ("empty", 0)
    
    override init() {
        print("init: Photo Service")
    }
    
    deinit {
        print("deinit: Photo Service")
    }
    
    func savePhoto(_ uiImage: UIImage) {
        let photoName = UUID().uuidString
        guard let jpegPhotoData = uiImage.jpegData(compressionQuality: 1.0) else {
            print("unable to load jpeg data from uiImage")
            return
        }
        
        guard let photoFileUrl = documentDirectoryFilePathUrl(forFileName: photoName, fileExtension: "jpg") else {
            print("file url not found for doc directory")
            return
        }
        
        writeData(jpegPhotoData, atPath: photoFileUrl)
        
        saveToRealm(url: photoFileUrl, name: photoName)
    }
    
    func requestUploadToCloud(photo: Photo) {
        guard !photo.isUploaded else { return }
        guard !(pendingUploadRequests.contains { $0.name == photo.name }) else { return }
        pendingUploadRequests.append(photo)
        
        guard !uploadInProgress else { return }
        uploadInProgress = true
    
        Task {
            await processNextPhotoUpload()
        }
    }
    
    
    @MainActor private func processNextPhotoUpload() async {
        guard !pendingUploadRequests.isEmpty, let photo = pendingUploadRequests.first else {
            uploadInProgress = false
            return
        }
        
        let photoDTO = PhotoDTO(from: photo)
        
        await uploadToCloud(photoDTO)
        
        pendingUploadRequests.removeFirst()
        print("Pending uploads count: \(pendingUploadRequests.count)")
        
        // Recursive
        await processNextPhotoUpload()
    }
    
    private func uploadToCloud(_ photo: PhotoDTO) async {
        let photoData: Data
        do {
            photoData = try Data(contentsOf: URL(filePath: photo.urlPathString))
        } catch {
            // to do
            print("uploadToCloud: data load error: ", error)
            return
        }
    
        let result = await networkManager.post(photoData: photoData, forPhoto: photo)
        
        switch result {
        case .success(_):
            await MainActor.run {
                guard let photoObject: Photo = realmManager.objectForKey(primaryKey: photo.name) else { return }
                realmManager.update {
                    photoObject.isUploaded = true
                }
            }
        case .failure(_):
            break
        }
    }
    
    @discardableResult
    private func saveToRealm(url: URL, name: String) -> Photo {
        let photo = Photo()
        photo.captureDate = Date()
        photo.name = name
        photo.urlPathString = url.path
        
        realmManager.add(object: photo)
        return photo
    }
    
    private func writeData(_ data: Data, atPath pathURL: URL) {
        do {
            try data.write(to: pathURL)
            print("Image saved to document directory")
        } catch {
            print("error writing image to documentDic: ", error)
        }
    }
    
    func documentDirectoryFilePathUrl(forFileName name: String, fileExtension: String) -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(name).appendingPathExtension(fileExtension)
    }
    
    func allPhotos() -> Results<Photo> {
        realmManager.readAll()
    }
    
    func uploadFailedPhotosToCloud() {
        
    }
    
    private func uploadToCloud(photo: Photo, data photoData: Data) {
        let photoDTO = PhotoDTO(from: photo)
        Task {
            let result = await networkManager.post(photoData: photoData, forPhoto: photoDTO)
            switch result {
            case .success(_):
                await MainActor.run {
                    guard let photoObject: Photo = realmManager.objectForKey(primaryKey: photoDTO.name) else { return }
                    realmManager.update {
                        photoObject.isUploaded = true
                    }
                }
            case .failure(_):
                // to do
                break
            }
        }
    }
}

extension PhotoService: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        guard let taskID = task.taskDescription else { return }
        let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        uploadingTaskProgress = (taskID, progress)
        
        print("progress: ", totalBytesSent , totalBytesExpectedToSend)
        
    }
}
