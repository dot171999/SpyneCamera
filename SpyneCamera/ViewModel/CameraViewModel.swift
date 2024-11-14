//
//  CameraViewModel.swift
//  SpyneCamera
//
//  Created by Aryan Sharma on 11/11/24.
//

import Foundation
import RealmSwift
import PhotosUI

@Observable class CameraViewModel {
    private let photoService: PhotoManager = PhotoManager()
    
    private(set) var cameraPreviewFrameImage: UIImage?
    private(set) var capturedImage: UIImage?
    private(set) var errorMessage: String = ""
    var showErrorAlert: Bool = false
    private var isAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            var isAuthorized = status == .authorized
            
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }
            return isAuthorized
        }
    }
    
    init() {
        print("init: CameraViewModel")
    }
    
    deinit {
        print("deinit: CameraViewModel")
    }
    
    @ObservationIgnored lazy private var videoBufferDelgate: VideoDataOutputSampleBufferDelegate = {
        let videoBufferDelgate = VideoDataOutputSampleBufferDelegate(completion: { [unowned self] result in
            switch result {
            case .success(let uiImage):
                self.capturedImage = uiImage
            case .failure(let error):
                break
            }
        })
        return videoBufferDelgate
    }()
    
    @ObservationIgnored lazy private var photoCaptureDelegate: PhotoCaptureDelegate = {
        let photoCaptureDelegate = PhotoCaptureDelegate(completion: { [unowned self] result in
            switch result {
            case .success(let uiImage):
                self.cameraPreviewFrameImage = uiImage
                do {
                    try self.photoService.savePhoto(uiImage)
                } catch {
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            case .failure(let error):
                break
            }
        })
        return photoCaptureDelegate
    }()
    
    @ObservationIgnored lazy private var captureSessionManager: CaptureSessionManager = { [unowned self] in
        return CaptureSessionManager(videoBufferDelgate: self.videoBufferDelgate)
    }()
    
    @MainActor
    func setup() async {
        guard await isAuthorized else {
            errorMessage = "Need Camera Permission."
            showErrorAlert = true
            return
        }
        do {
            try await captureSessionManager.configureSession()
            await captureSessionManager.startSession()
        } catch {
            if let error = error as? CaptureSessionError {
                errorMessage = error.localizedDescription
                showErrorAlert = true
            }
        }
    }
    
    func stopSession() {
        Task {
            await captureSessionManager.stopSession()
        }
    }
    
    func clickPhoto() {
        Task {
            do {
                try await captureSessionManager.capturePhoto(photoCaptureDelegate: photoCaptureDelegate)
            } catch {
                if let error = error as? CaptureSessionError {
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }
        }
    }
}
