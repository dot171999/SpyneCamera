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
    private let photoManager: PhotoManager
    private let toastManager: ToastManager
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
            #if targetEnvironment(simulator)
            return true
            #else
            return isAuthorized
            #endif
        }
    }
    
    init(toastManager: ToastManager = ToastManager.shared, photoManager: PhotoManager = PhotoManager()) {
        self.photoManager = photoManager
        self.toastManager =  toastManager
        print("init: CameraViewModel")
    }
    
    deinit {
        print("deinit: CameraViewModel")
    }
    
    @ObservationIgnored lazy private var videoBufferDelgate: VideoDataOutputSampleBufferDelegate = {
        let videoBufferDelgate = VideoDataOutputSampleBufferDelegate(completion: { [weak self] result in
            switch result {
            case .success(let uiImage):
                self?.cameraPreviewFrameImage = uiImage
            case .failure(let error):
                break
            }
        })
        return videoBufferDelgate
    }()
    
    @ObservationIgnored lazy private var photoCaptureDelegate: PhotoCaptureDelegate = {
        let photoCaptureDelegate = PhotoCaptureDelegate(completion: { [weak self] result in
            switch result {
            case .success(let uiImage):
                self?.capturedImage = uiImage
                do {
                    try self?.photoManager.savePhoto(uiImage)
                    self?.toastManager.show(message: "Photo saved to storage.")
                } catch {
                    self?.errorMessage = error.localizedDescription
                    self?.showErrorAlert = true
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
            errorMessage = CaptureSessionError.needCameraPermission.localizedDescription
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
