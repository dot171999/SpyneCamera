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
    private let photoManager: PhotoManagerProtocol
    private let toastManager: ToastManagerProtocol
    private(set) var cameraPreviewFrameImage: UIImage?
    private(set) var capturedImage: UIImage?
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
    private(set) var errorMessage: String = ""
    var showErrorAlert: Bool = false
    
    init(toastManager: ToastManagerProtocol = ToastManager.shared, 
         photoManager: PhotoManagerProtocol = PhotoManager()
    ) {
        self.photoManager = photoManager
        self.toastManager =  toastManager
    }
    
    @ObservationIgnored lazy private var videoBufferDelgate: VideoDataOutputSampleBufferDelegate = {
        let videoBufferDelgate = VideoDataOutputSampleBufferDelegate(completion: { [weak self] result in
            switch result {
            case .success(let uiImage):
                guard let self = self else { return }
                Task {
                    await MainActor.run {
                        self.cameraPreviewFrameImage = uiImage
                    }
                }
                break
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
                guard let self = self else { return }
                Task {
                    await MainActor.run {
                        self.capturedImage = uiImage
                        do {
                            try self.photoManager.savePhoto(uiImage)
                            self.toastManager.show(message: "Photo saved to storage.")
                        } catch {
                            self.errorMessage = error.localizedDescription
                            self.showErrorAlert = true
                        }
                    }
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
    
    func resetErrorMessage() {
        errorMessage = ""
    }
}
